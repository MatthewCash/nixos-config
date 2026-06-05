{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [
        qpwgraph
    ];

    xdg.configFile."rncbc.org/qpwgraph.conf".text = ''
        [GraphView]
        ConnectThroughNodes=true
        RepelOverlappingNodes=true
        SortOrder=0
        SortType=2
        ZoomRange=true
    '';
}
