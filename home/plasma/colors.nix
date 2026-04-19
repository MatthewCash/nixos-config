{ lib, accentColor, ... }:

let
  rgbText = lib.concatStringsSep "," (map toString (with accentColor; [ r g b ]));
  background = "0,0,0";

  scheme = {
    "ColorEffects:Disabled" = {
      Color = "56,56,56";
      ColorAmount = 0;
      ColorEffect = 0;
      ContrastAmount = 0.65;
      ContrastEffect = 1;
      IntensityAmount = 0.1;
      IntensityEffect = 2;
    };

    "ColorEffects:Inactive" = {
      ChangeSelectionColor = true;
      Color = "112,111,110";
      ColorAmount = 0.025000000000000001;
      ColorEffect = 2;
      ContrastAmount = 0.10000000000000001;
      ContrastEffect = 2;
      Enable = false;
      IntensityAmount = 0;
      IntensityEffect = 0;
    };

    "Colors:Button" = {
      BackgroundAlternate = background;
      BackgroundNormal = background;
      DecorationFocus = rgbText;
      DecorationHover = rgbText;
      ForegroundActive = "61,174,233";
      ForegroundInactive = "102,106,115";
      ForegroundLink = "41,128,185";
      ForegroundNegative = "237,37,78";
      ForegroundNeutral = "255,106,0";
      ForegroundNormal = "195,199,209";
      ForegroundPositive = "113,247,159";
      ForegroundVisited = "82,148,226";
    };

    "Colors:Selection" = {
      BackgroundAlternate = background;
      BackgroundNormal = rgbText;
      DecorationFocus = rgbText;
      DecorationHover = rgbText;
      ForegroundActive = "252,252,252";
      ForegroundInactive = "211,218,227";
      ForegroundLink = "253,188,75";
      ForegroundNegative = "237,37,78";
      ForegroundNeutral = "255,106,0";
      ForegroundNormal = "254,254,254";
      ForegroundPositive = "113,247,159";
      ForegroundVisited = "189,195,199";
    };

    "Colors:Tooltip" = {
      BackgroundAlternate = background;
      BackgroundNormal = background;
      DecorationFocus = rgbText;
      DecorationHover = rgbText;
      ForegroundActive = "61,174,233";
      ForegroundInactive = "102,106,115";
      ForegroundLink = "41,128,185";
      ForegroundNegative = "237,37,78";
      ForegroundNeutral = "255,106,0";
      ForegroundNormal = "211,218,227";
      ForegroundPositive = "113,247,159";
      ForegroundVisited = "82,148,226";
    };

    "Colors:View" = {
      BackgroundAlternate = background;
      BackgroundNormal = background;
      DecorationFocus = rgbText;
      DecorationHover = rgbText;
      ForegroundActive = "0,193,228";
      ForegroundInactive = "102,106,115";
      ForegroundLink = "82,148,226";
      ForegroundNegative = "237,37,78";
      ForegroundNeutral = "255,106,0";
      ForegroundNormal = "211,218,227";
      ForegroundPositive = "113,247,159";
      ForegroundVisited = "124,183,255";
    };

    "Colors:Window" = {
      BackgroundAlternate = background;
      BackgroundNormal = background;
      DecorationFocus = rgbText;
      DecorationHover = rgbText;
      ForegroundActive = "61,174,233";
      ForegroundInactive = "102,106,115";
      ForegroundLink = "41,128,185";
      ForegroundNegative = "237,37,78";
      ForegroundNeutral = "255,106,0";
      ForegroundNormal = "211,218,227";
      ForegroundPositive = "113,247,159";
      ForegroundVisited = rgbText;
    };

    General = {
      ColorScheme = "Main";
      Name = "Main";
      shadeSortColumn = true;
    };

    KDE = {
      contrast = 4;
    };

    WM = {
      activeBackground = background;
      activeBlend = background;
      activeForeground = "211,218,227";
      inactiveBackground = background;
      inactiveBlend = background;
      inactiveForeground = "102,106,115";
    };
  };
in
  lib.generators.toINI {} scheme
