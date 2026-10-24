{ pkgsUnstable, accentColor }:

let
    accentRgb = builtins.concatStringsSep ", " (map builtins.toString (with accentColor; [ r g b ]));

    guitarix-mfd-css = pkgsUnstable.writeText "gx_head_Nebula.css" /* css */ ''
        @import url("gx_head_Guitarix.css");

        * {
            color: #d8ded8;
            background-color: transparent;
            background-image: none;
            text-shadow: none;
            -gtk-icon-shadow: none;
        }

        window,
        window.background,
        dialog {
            background-color: rgba(8, 10, 9, 0.58);
            background-image: none;
        }

        menu,
        menu.background,
        .context-menu,
        window.popup,
        popover,
        popover.background,
        tooltip,
        treeview,
        entry,
        scrolledwindow {
            color: #d8ded8;
            background-image: none;
            border-color: rgba(210, 220, 210, 0.34);
        }

        menu,
        menu.background,
        .context-menu,
        window.popup,
        popover,
        popover.background {
            background-color: #000000;
        }

        tooltip,
        treeview,
        entry,
        scrolledwindow {
            background-color: transparent;
        }

        gx-paint-box {
            -GxPaintBox-icon-set: 5;
            -GxPaintBox-stock-gxhead: "live_wallpaper_dark.png";
        }

        #main_vpaned,
        #monobox,
        #upper_rackbox,
        #stereorackbox,
        #monorackcontainer,
        #hboxcenter,
        #hboxmain,
        #ampdetails,
        #tableampright,
        #PLUI-ampstack,
        #effects_frame_paintbox,
        #rackcontainer,
        #preset_scrolledbox,
        #amp_background,
        #tunerbox,
        .rackmain,
        .rackmini,
        .PL-LV2,
        .PL-LADSPA,
        .tab_rack,
        .meterbox {
            background-color: transparent;
            background-image: none;
            border: 1px solid rgba(210, 220, 210, 0.32);
            border-radius: 0px;
            box-shadow: inset 0 0 0 1px rgba(220, 220, 220, 0.08),
                        inset 0 0 18px rgba(0, 0, 0, 0.65),
                        0 0 10px rgba(210, 220, 210, 0.08);
        }

        #PLUI-ampstack gx-paint-box,
        #PLUI-ampstack .rackmain,
        #rackbox,
        .rackbox,
        .rackmain,
        .rackmini,
        .PL-LV2,
        .PL-LADSPA {
            -GxPaintBox-paint-func: "";
            -GxPaintBox-alternate-box: 0 0 0 0;
            background-color: transparent;
            background-image: none;
        }

        #upper_rackbox,
        #stereorackbox,
        #monorackcontainer,
        #hboxmain,
        #PLUI-ampstack,
        #PLUI-ampstack gx-paint-box,
        #PLUI-ampstack .rackmain,
        #rackcontainer {
            border: none;
            box-shadow: none;
        }

        #rackbox,
        .rackbox,
        .rackmain,
        .rackmini,
        .PL-LV2,
        .PL-LADSPA,
        .tab_rack,
        #rack_unit_title_bar,
        #rackcontainer .rackbox,
        #rackcontainer .rackmain,
        #rackcontainer .rackmini,
        #rackcontainer .PL-LV2,
        #rackcontainer .PL-LADSPA,
        #rackcontainer .tab_rack,
        #rackcontainer #rack_unit_title_bar {
            border: none;
            border-radius: 0px;
            box-shadow: none;
        }

        button,
        checkbutton,
        combobox,
        entry,
        menuitem {
            color: #d8ded8;
            background-color: transparent;
            background-image: none;
            border: 1px solid rgba(210, 220, 210, 0.22);
            border-radius: 0px;
            text-shadow: none;
            box-shadow: none;
        }

        button:hover,
        button:hover *,
        checkbutton:hover,
        checkbutton:hover *,
        menuitem:hover,
        menuitem:hover * {
            color: #f0f4f0;
            background-color: transparent;
            border-color: rgba(210, 220, 210, 0.34);
            box-shadow: none;
        }

        button:checked,
        button:active,
        checkbutton:checked,
        checkbutton:active,
        treeview:selected {
            color: ${accentColor.hex};
            background-color: transparent;
            background-image: none;
            text-shadow: none;
        }

        #rackcontainer button:checked,
        #rackcontainer button:active,
        #rackcontainer checkbutton:checked,
        #rackcontainer checkbutton:active,
        #tunerbox button:checked,
        #tunerbox button:active,
        #tunerbox checkbutton:checked,
        #tunerbox checkbutton:active {
            background-color: transparent;
            background-image: none;
        }

        #effects_toolpalette toolitemgroup button,
        #effects_toolpalette toolitemgroup button label,
        #fload label,
        gx-simple-value-display,
        #preset_treeview:selected,
        #preset_scrolledbox treeview:checked {
            color: #f0f4f0;
        }

        #rackcontainer .effect_title,
        #effect_title,
        #drag_widget .effect_title,
        #rack_label,
        .rack_label,
        #Value,
        #ampbox label,
        #beffekt_label,
        .tab_rack label,
        #rack_effect_label {
            color: #d8ded8;
            font: condensed 8pt "Roboto";
            letter-spacing: 0.08em;
            text-shadow: none;
        }

        #rackcontainer .effect_title,
        #effect_title,
        #drag_widget .effect_title {
            color: #f0f4f0;
            font: bold condensed 10pt "Roboto";
            text-shadow: none;
        }

        gx-fast-meter {
            -GxFastMeter-clr-bottom: #171917;
            -GxFastMeter-clr-middle: ${accentColor.hex};
            -GxFastMeter-clr-top: ${accentColor.hex};
            -GxFastMeter-over: ${accentColor.hex};
            border-color: rgba(${accentRgb}, 0.65);
            box-shadow: 0 0 8px rgba(${accentRgb}, 0.30);
        }

        gx-wave-view {
            color: rgba(${accentRgb}, 0.85);
            -GxWaveView-box-gradient: {
                { 0, 0, 0, 0, 65535 },
                { 0, 0, 0, 0, 65535 }};
        }

        separator,
        separator.horizontal,
        separator.vertical {
            background-color: transparent;
            box-shadow: 0 0 7px rgba(${accentRgb}, 0.45);
        }

        scrollbar,
        scrollbar *,
        scrollbar slider,
        scrollbar trough {
            background-color: transparent;
            background-image: none;
            border-color: transparent;
            box-shadow: none;
            margin: 0;
            min-width: 0;
            min-height: 0;
            opacity: 0;
        }

        scrollbar slider:hover,
        scrollbar slider:active {
            background-color: transparent;
            background-image: none;
            box-shadow: none;
        }

        scrollbar.vertical slider {
            min-width: 0;
        }

        scrollbar.horizontal slider {
            min-height: 0;
        }

        progressbar progress,
        scale highlight,
        checkbutton check:checked,
        radiobutton radio:checked {
            color: ${accentColor.hex};
            background-color: transparent;
            border-color: ${accentColor.hex};
        }

        #rackcontainer button,
        #rackcontainer button image,
        #rackcontainer button label,
        #preset_status,
        #preset_status label,
        #presets\:barbutton,
        #presets\:barbutton *,
        #effect_on_off.gx_switch,
        .gx_effect_on_off.gx_switch,
        #effect_on_off.gx_switch check,
        .gx_effect_on_off.gx_switch check {
            color: #d8ded8;
            background-color: transparent;
            border-color: rgba(210, 220, 210, 0.28);
            text-shadow: none;
            box-shadow: inset 0 0 0 1px rgba(220, 220, 220, 0.05), 0 0 5px rgba(210, 220, 210, 0.08);
        }

        #rackcontainer button:hover,
        #rackcontainer button:hover image,
        #rackcontainer button:hover label,
        #effect_on_off.gx_switch:hover,
        .gx_effect_on_off.gx_switch:hover,
        #effect_on_off.gx_switch:hover check,
        .gx_effect_on_off.gx_switch:hover check,
        #effect_on_off.gx_switch:checked,
        .gx_effect_on_off.gx_switch:checked,
        #effect_on_off.gx_switch:checked check,
        .gx_effect_on_off.gx_switch:checked check {
            color: #f0f4f0;
            background-color: transparent;
            border-color: rgba(210, 220, 210, 0.40);
            box-shadow: inset 0 0 0 1px rgba(220, 220, 220, 0.08), 0 0 6px rgba(210, 220, 210, 0.12);
        }

        #presets\:barbutton,
        #presets\:barbutton:hover,
        #presets\:barbutton:checked,
        #presets\:barbutton:active {
            border-color: rgba(0, 0, 0, 0);
            box-shadow: none;
        }

        #rackcontainer gx-vslider,
        gx-hslider,
        gx-vslider,
        gx-big-knob,
        gx-mid-knob,
        gx-small-knob,
        gx-small-knob-r {
            color: ${accentColor.hex};
            background-color: transparent;
            border-color: rgba(${accentRgb}, 0.70);
        }

        tooltip {
            border: 1px solid ${accentColor.hex};
            box-shadow: 0 0 10px rgba(${accentRgb}, 0.45);
        }

        *:disabled,
        *:disabled * {
            color: #606660;
            text-shadow: none;
            -gtk-icon-shadow: none;
        }
    '';

in

pkgsUnstable.runCommand "guitarix-targeting-computer-skin" { } /* bash */ ''
        mkdir -p $out

        ln -s ${pkgsUnstable.guitarix}/share/gx_head/skins/* $out/
        rm $out/gx_head_Guitarix.css
        rm $out/gx_head_Nebula.css
        rm $out/Nebula
        mkdir -p $out/Nebula
        ln -s ${pkgsUnstable.guitarix}/share/gx_head/skins/Plain_Dark/* $out/Nebula/
        ${pkgsUnstable.gnused}/bin/sed \
            -e 's/#ff8c00/${accentColor.hex}/g' \
            -e 's/#ff9000/${accentColor.hex}/g' \
            -e 's/#b96901/${accentColor.hex}/g' \
            -e 's/#d4cd00/${accentColor.hex}/g' \
            -e 's/#ffa633/${accentColor.hex}/g' \
            -e 's/#cc7300/${accentColor.hex}/g' \
            -e 's/#995600/${accentColor.hex}/g' \
            -e 's/rgba(255,207,0,0.5)/rgba(${accentRgb},0.5)/g' \
            -e 's/rgba(255,51,0,0.5)/rgba(${accentRgb},0.5)/g' \
            ${pkgsUnstable.guitarix}/share/gx_head/skins/gx_head_Guitarix.css > $out/gx_head_Guitarix.css
        ln -s ${guitarix-mfd-css} $out/gx_head_Nebula.css
    ''
