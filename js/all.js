function changeQuickStart(name, selected) {
    var holder = document.getElementById("quickstart");
    var target = document.getElementById(name);
    if(target == null) {
        return false;
    }

    /* remove all elements from the holder */
    var lastChild;
    while((lastChild = holder.lastChild) != null) {
        holder.removeChild(lastChild);
    }

    /* copy all elements from the target to the holder */
    var children = target.childNodes;
    var childrenLength = children.length;
    for(var i=0; i < childrenLength; i++) {
        holder.appendChild(children[i].cloneNode(true));
    }

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
