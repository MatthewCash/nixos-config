#include "orderedtaskmanagerproxy.h"

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmawindowmanagement.h>
#include <KWayland/Client/registry.h>

#include <qqml.h>
#include <QGuiApplication>
#include <QUrl>
#include <QSet>
#include <QFileInfo>
#include <QRegularExpression>

OrderedTasksModel::OrderedTasksModel(QObject *parent)
    : TaskManager::TasksModel(parent)
{
    initWayland();
}

void OrderedTasksModel::initWayland()
{
    if (QGuiApplication::platformName() != QLatin1String("wayland")) {
        return;
    }

    using namespace KWayland::Client;

    auto *connection = ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }

    auto *registry = new Registry(this);
    registry->create(connection);

    connect(registry, &Registry::interfacesAnnounced, this, [this, registry]() {
        const auto iface = registry->interface(Registry::Interface::PlasmaWindowManagement);
        if (iface.name == 0) {
            return;
        }

        m_windowManagement = registry->createPlasmaWindowManagement(iface.name, iface.version, this);
        if (!m_windowManagement || !m_windowManagement->isValid()) {
            return;
        }

        auto cacheWindow = [this](PlasmaWindow *window) {
            const QString uuid = QString::fromUtf8(window->uuid());
            const QString appId = window->appId();
            const quint32 pid = window->pid();

            m_windowAppIds[uuid] = appId;
            m_windowPids[uuid] = pid;
            refreshPidAppIds(pid);
            resortForAppIdChange();

            connect(window, &PlasmaWindow::appIdChanged, this, [this, window]() {
                const QString uuid = QString::fromUtf8(window->uuid());
                const QString newAppId = window->appId();
                const quint32 oldPid = m_windowPids.value(uuid);
                const quint32 newPid = window->pid();

                m_windowAppIds[uuid] = newAppId;
                m_windowPids[uuid] = newPid;
                refreshPidAppIds(oldPid);
                if (newPid != oldPid) {
                    refreshPidAppIds(newPid);
                }
                resortForAppIdChange();
            });
            connect(window, &PlasmaWindow::unmapped, this, [this, window]() {
                const QString uuid = QString::fromUtf8(window->uuid());
                const quint32 oldPid = m_windowPids.value(uuid);
                m_windowAppIds.remove(uuid);
                m_windowPids.remove(uuid);

                refreshPidAppIds(oldPid);
                resortForAppIdChange();
            });
        };

        for (auto *window : m_windowManagement->windows()) {
            cacheWindow(window);
        }

        connect(m_windowManagement, &PlasmaWindowManagement::windowCreated, this, cacheWindow);

        resortForAppIdChange();
    });

    registry->setup();
    connection->roundtrip();
}

QStringList OrderedTasksModel::orderedAppIds() const
{
    return m_orderedAppIds;
}

void OrderedTasksModel::setOrderedAppIds(const QStringList &ids)
{
    QStringList normalized;
    QSet<QString> seen;

    for (const QString &id : ids) {
        const QString n = normalizeId(id);

        if (!n.isEmpty() && !seen.contains(n)) {
            seen.insert(n);
            normalized.append(n);
        }
    }

    if (m_orderedAppIds != normalized) {
        m_orderedAppIds = normalized;
        sort(0);
        Q_EMIT orderedAppIdsChanged();
    }
}

QString OrderedTasksModel::normalizeId(const QString &value)
{
    QString result = value.trimmed().toLower();

    if (result.startsWith(QLatin1String("applications:"))) {
        result.remove(0, 13);
    }

    if (result.endsWith(QLatin1String(".desktop"))) {
        result.chop(8);
    }

    return result;
}

void OrderedTasksModel::refreshPidAppIds(quint32 pid)
{
    if (pid == 0) {
        return;
    }

    QStringList appIds;
    for (auto it = m_windowPids.constBegin(); it != m_windowPids.constEnd(); ++it) {
        if (it.value() != pid) {
            continue;
        }

        const QString appId = m_windowAppIds.value(it.key());
        if (!appId.isEmpty() && !appIds.contains(appId)) {
            appIds.append(appId);
        }
    }

    if (appIds.isEmpty()) {
        m_pidAppIds.remove(pid);
    } else {
        m_pidAppIds[pid] = appIds;
    }
}

void OrderedTasksModel::resortForAppIdChange()
{
    if (!m_orderedAppIds.isEmpty()) {
        sort(0);
    }
}

QStringList OrderedTasksModel::normalizedCandidates(const QVariant &value)
{
    QStringList candidates;

    if (value.canConvert<QUrl>()) {
        const QUrl url = value.toUrl();
        QString urlStr = url.toString(QUrl::RemoveQuery);
        candidates.append(normalizeId(urlStr));

        if (url.scheme() == QLatin1String("applications")) {
            candidates.append(normalizeId(url.path()));
        } else if (url.isLocalFile()) {
            candidates.append(normalizeId(QFileInfo(url.toLocalFile()).fileName()));
        }
    } else if (value.typeId() == QMetaType::QStringList) {
        for (const QString &entry : value.toStringList()) {
            candidates.append(normalizedCandidates(entry));
        }
        return candidates;
    } else {
        QString str = value.toString();
        QString norm = normalizeId(str);
        if (!norm.isEmpty()) {
            candidates.append(norm);
        }

        if (!str.contains(QLatin1Char('/')) && !str.contains(QLatin1Char(':'))) {
            QStringList wmClassParts = str.split(QLatin1Char(','), Qt::SkipEmptyParts);
            if (wmClassParts.size() != 2) {
                wmClassParts = str.split(QLatin1Char(' '), Qt::SkipEmptyParts);
            }
            if (wmClassParts.size() == 2) {
                QString appClass = wmClassParts.at(1).trimmed();
                appClass.remove(QLatin1Char('"'));
                candidates.append(normalizeId(appClass));
            }
        }
    }

    candidates.removeDuplicates();
    return candidates;
}

int OrderedTasksModel::priorityForIndex(const QModelIndex &index) const
{
    if (m_orderedAppIds.isEmpty()) {
        return std::numeric_limits<int>::max();
    }

    // Raw Wayland app_id from KWin (e.g. "org.mozilla.Firefox.floating")
    // before KDesktopFile resolution. This is the highest-priority candidate.
    const QVariantList winIds = index.data(
        TaskManager::AbstractTasksModel::WinIdList).toList();
    QStringList rawAppIds;
    for (const QVariant &winId : winIds) {
        const QString appId = m_windowAppIds.value(winId.toString());
        if (!appId.isEmpty()) {
            rawAppIds.append(normalizeId(appId));
        }
    }

    const int rawPriority = priorityForCandidates(rawAppIds);
    if (rawPriority != std::numeric_limits<int>::max()) {
        return rawPriority;
    }

    QStringList roleCandidates;
    const QVariantList values = {
        index.data(TaskManager::AbstractTasksModel::AppId),
        index.data(TaskManager::AbstractTasksModel::LauncherUrlWithoutIcon),
        index.data(TaskManager::AbstractTasksModel::LauncherUrl),
        index.data(TaskManager::AbstractTasksModel::AppName),
        index.data(Qt::DisplayRole),
    };

    for (const QVariant &value : values) {
        roleCandidates.append(normalizedCandidates(value));
    }

    const int rolePriority = priorityForCandidates(roleCandidates);
    if (rolePriority != std::numeric_limits<int>::max()) {
        return rolePriority;
    }

    const QVariant pidVariant = index.data(TaskManager::AbstractTasksModel::AppPid);
    if (!pidVariant.isValid()) {
        return std::numeric_limits<int>::max();
    }

    const quint32 pid = pidVariant.toUInt();
    if (pid == 0) {
        return std::numeric_limits<int>::max();
    }

    QStringList pidCandidates;
    const QList<QString> appIds = m_pidAppIds.value(pid);
    for (const QString &appId : appIds) {
        const QString normalized = normalizeId(appId);
        if (!normalized.isEmpty()) {
            pidCandidates.append(normalized);
        }
    }
    pidCandidates.removeDuplicates();

    if (pidCandidates.size() != 1) {
        return std::numeric_limits<int>::max();
    }

    return priorityForCandidates(pidCandidates);
}

int OrderedTasksModel::priorityForCandidates(const QStringList &candidates) const
{
    QStringList normalized = candidates;
    normalized.removeDuplicates();

    int best = std::numeric_limits<int>::max();
    for (const QString &candidate : normalized) {
        int pos = m_orderedAppIds.indexOf(candidate);
        if (pos != -1 && pos < best) {
            best = pos;
        }
    }

    return best;
}

bool OrderedTasksModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    const int leftPriority = priorityForIndex(left);
    const int rightPriority = priorityForIndex(right);

    if (leftPriority != rightPriority) {
        return leftPriority < rightPriority;
    }

    return TaskManager::TasksModel::lessThan(left, right);
}

static struct OrderedTaskManagerRegistrar {
    OrderedTaskManagerRegistrar()
    {
        qmlRegisterType<OrderedTasksModel>("OrderedTaskManager", 1, 0, "OrderedTasksModel");
    }
} s_reg;
