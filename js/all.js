function changeQuickStart(targetId, selected) {
    var $target = $('#' + targetId);
    if($target.length == 0) {
        return false;
    }

    var $preTarget = $('.current-language');
    $preTarget.hide();

    $target.show();
    $target.addClass('current-language');

    /* set css */
    var selectedNodes = document.getElementsByName("selected");
    var selectedNodesLength = selectedNodes.length;
    for(var i=0; i < selectedNodesLength; i++) {
        var selectedNode = selectedNodes[i];
        selectedNode.className = "";
        selectedNode.name = "";
    }
    selected.name = "selected";
    selected.className = "selected";

    return false;
}
