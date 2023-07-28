<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!-- lisLinkDisplayer.jsp -->
<tiles:importAttribute />
<style>
  div#geneLinks li { margin-top:10px; margin-bottom:10px; }
  div#regionLinks li { margin-top:10px; margin-bottom:10px; }
</style>

<h3 class="goog">LIS Linkouts</h3>
<div id="geneLinks"></div>
<div id="regionLinks"></div>

<script type="text/javascript">
// curl "https://services.lis.ncgr.org/gene_linkouts?genes=aesev.CIAT22838.gnm1.ann1.Ae01g00010"
// [
//     {
//         "text": "View aesev.CIAT22838.gnm1.ann1.Ae01g00010 in LegumeMine",
//         "href": "https://mines.legumeinfo.org/legumemine/gene:aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     },
//     {
//         "text": "View Funnotate phylogram for family of aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "href": "https://funnotate.legumeinfo.org/?gene_name=aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     },
//     {
//         "text": "View aesev.CIAT22838.gnm1.ann1.Ae01g00010 in Genome Context Viewer",
//         "href": "https://gcv.legumeinfo.org/gene;lis=aesev.CIAT22838.gnm1.ann1.Ae01g00010",
//         "method": "GET"
//     }
// ]
const geneLinkoutsUrl = "https://services.lis.ncgr.org/gene_linkouts?genes=${object.primaryIdentifier}";
fetch(geneLinkoutsUrl).then(function(response) {
    return response.json();
}).then(function(json) {
    var innerHtml = '<ul>';
    for(var i=0; i<json.length; i++) {
	innerHtml += '<li><a target="_blank" href="'+json[i].href+'">'+json[i].text+'</a></li>';
    }
    innerHtml += '</ul>';
    document.getElementById("geneLinks").innerHTML = innerHtml;
});

// curl "https://services.lis.ncgr.org/genomic_region_linkouts?genomic_regions=cicar.ICC4958.gnm2.Ca2:28707446-28710055"
// [
//     {
//         "text": "View cicar.ICC4958.gnm2.Ca2:28707446-28710055 in JBrowse2",
//         "href": "https://cicer.legumeinfo.org/tools/jbrowse2/?session=spec-%7B%22views%22%3A%5B%7B%22assembly%22%3A%22cicar.ICC4958.gnm2%22%2C%22loc%22%3A%22cicar.ICC4958.gnm2.Ca2%3A28707446-28710055%22%2C%22type%22%3A%20%22LinearGenomeView%22%2C%22tracks%22%3A%5B%22cicar.ICC4958.gnm2.ann1.LCVX.gene_models_main.gff3%22%5D%7D%5D%7D",
//         "method": "GET"
//     },
//     {
//         "text": "View cicar.ICC4958.gnm2.Ca2:28707446-28710055 in cicer Genome Context Viewer",
//         "href": "https://cicer.legumeinfo.org/tools/gcv//search?q=cicar.ICC4958.gnm2.Ca2:28707446-28710055&sources=cicer",
//         "method": "GET"
//     }
// ]
const region = '${object.chromosome.primaryIdentifier}:${object.chromosomeLocation.start}-${object.chromosomeLocation.end}';
const genomicRegionLinkoutsUrl = "https://services.lis.ncgr.org/genomic_region_linkouts?genomic_regions=" + region;
fetch(genomicRegionLinkoutsUrl).then(function(response) {
    return response.json();
}).then(function(json) {
    var innerHtml = '<ul>';
    for(var i=0; i<json.length; i++) {
	innerHtml += '<li><a target="_blank" href="'+json[i].href+'">'+json[i].text+'</a></li>';
    }
    innerHtml += '</ul>';
    document.getElementById("regionLinks").innerHTML = innerHtml;
});
</script>
<!-- /lisLinkDisplayer.jsp -->

