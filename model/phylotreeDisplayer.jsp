<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- phylotreeDisplayer.jsp -->
<html:xhtml />
<tiles:importAttribute />
<div class="collection-table">
    <h3 onClick="toggleTreeVisibility()">Phylotree Displayer</h3>
    <svg id="tree_display" style="display:none" />
</div>
<script>
 var newick_tree = "${newick}";
 // create a tree layout object
 // render to this SVG element
 var tree = d3.layout.phylotree().svg(d3.select("#tree_display"));
 // parse the Newick into a d3 hierarchy object with additional fields
 // layout and render the tree
 tree(newick_tree).layout();
</script>
<script>
 function toggleTreeVisibility() {
     var x = document.getElementById("tree_display");
     if (x.style.display === "none") {
         x.style.display = "block";
     } else {
         x.style.display = "none";
     }
 }
</script>
<!-- /phylotreeDisplayer.jsp -->
