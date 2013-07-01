function changeQuickStart(targetId, selected) {
    var holder = document.getElementById("quickstart");
    var title = document.getElementById("language");
    var target = document.getElementById(targetId);

    if(target == null) {
        return false;
    }

    /* remove all elements from the holder and title */
    var lastChild;
    while((lastChild = holder.lastChild) != null) {
        holder.removeChild(lastChild);
    }
    while((lastChild = title.lastChild) != null) {
        title.removeChild(lastChild);
    }

    var children = target.childNodes;
    var childrenLength = children.length;

    /* copy first element from target to title */
    title.appendChild(children[0].cloneNode(true));

    /* copy remaining elements from target to holder */
    for(var i=1; i < childrenLength; i++) {
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
