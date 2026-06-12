#pragma once

#include <taskmanager/abstracttasksmodel.h>
#include <taskmanager/tasksmodel.h>

#include <QHash>
#include <QStringList>
#include <limits>

namespace KWayland::Client {
class PlasmaWindowManagement;
}

class OrderedTasksModel : public TaskManager::TasksModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList orderedAppIds READ orderedAppIds WRITE setOrderedAppIds NOTIFY orderedAppIdsChanged)

public:
    explicit OrderedTasksModel(QObject *parent = nullptr);

    QStringList orderedAppIds() const;
    void setOrderedAppIds(const QStringList &ids);

signals:
    void orderedAppIdsChanged();

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

private:
    void initWayland();
    int priorityForIndex(const QModelIndex &index) const;
    int priorityForCandidates(const QStringList &candidates) const;
    static QStringList normalizedCandidates(const QVariant &value);
    static QString normalizeId(const QString &value);
    void refreshPidAppIds(quint32 pid);
    void resortForAppIdChange();

    QStringList m_orderedAppIds;
    KWayland::Client::PlasmaWindowManagement *m_windowManagement = nullptr;
    QHash<QString, QString> m_windowAppIds; // window UUID -> raw Wayland app_id
    QHash<QString, quint32> m_windowPids; // window UUID -> PID
    QHash<quint32, QStringList> m_pidAppIds; // PID -> raw Wayland app_ids
};
