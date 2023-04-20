<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!-- lisLinkDisplayer.jsp -->
<tiles:importAttribute />
<style>
	div#lisLinks li { margin-top:10px; margin-bottom:10px; }
</style>

<h3 class="goog">LIS Link Service</h3>
<div id="lisLinks"></div>
<script type="text/javascript">
// https://linkouts.services.legumeinfo.org/gene_linkouts?genes=aesev.CIAT22838.gnm1.ann1.Ae01g00010
// returns:
// [
//     {
//         "text": "View aesev.CIAT22838.gnm1.ann1.Ae01g00010 in Genome Context Viewer",
//         "href": "https://gcv.legumeinfo.org/gene;lis=aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     },
//     {
//         "text": "View aesev.CIAT22838.gnm1.ann1.Ae01g00010 in LegumeMine",
//         "href": "https://mines.legumeinfo.org/legumemine/gene:aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     },
//     {
//         "text": "View aesev.CIAT22838.gnm1.ann1.Ae01g00010 in Funnotate phylogram",
//         "href": "https://funnotate.legumeinfo.org/?gene_name=aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     }
// ]
var lisJsonUrl = "https://linkouts.services.legumeinfo.org/gene_linkouts?genes=${object.primaryIdentifier}";
fetch(lisJsonUrl).then(function(response) {
    return response.json();
}).then(function(json) {
    var innerHtml = '<ul>';
    for(var i=0; i<json.length; i++) {
	innerHtml += '<li><a target="_blank" href="'+json[i].href+'">'+json[i].text+'</a></li>';
    }
    innerHtml += '</ul>';
    document.getElementById("lisLinks").innerHTML = innerHtml;
});
</script>
<!-- /lisLinkDisplayer.jsp -->

