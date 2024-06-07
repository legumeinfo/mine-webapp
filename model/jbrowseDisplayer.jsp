<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jBrowseDisplayer.jsp -->

<script type="text/javascript">
// getLinkout() finds the first JBrowse 2 linkout, and inserts it into the iframe and the "Centre on" link.
function getLinkout() {
  const geneLinkoutsUrl = "https://services.lis.ncgr.org/gene_linkouts?genes=${reportObject.object.primaryIdentifier}";
  fetch(geneLinkoutsUrl).then(function(response) {
    return response.json();
  }).then(function(json) {
    for (var i = 0; i < json.length; i++) {
      if (json[i].href.includes('jbrowse2')) {
        document.getElementById('jbrowseLink').href = json[i].href;
        document.getElementById('jbrowseFrame').src = json[i].href;
        return;
      }
    }
  });

  const region = '${reportObject.object.chromosome.primaryIdentifier}:${reportObject.object.chromosomeLocation.start}-${reportObject.object.chromosomeLocation.end}';
  const genomicRegionLinkoutsUrl = "https://services.lis.ncgr.org/genomic_region_linkouts?genomic_regions=" + region;
  fetch(genomicRegionLinkoutsUrl).then(function(response) {
    return response.json();
  }).then(function(json) {
    for (var i = 0; i < json.length; i++) {
      if (json[i].href.includes('jbrowse2')) {
        document.getElementById('jbrowseLink').href = json[i].href;
        document.getElementById('jbrowseFrame').src = json[i].href;
        return;
      }
    }
  });
}

getLinkout();
</script>

<c:if test="${((!empty reportObject.object.chromosomeLocation && !empty reportObject.object.chromosome)
                || cld.unqualifiedName == 'Chromosome') && cld.unqualifiedName != 'ChromosomeBand'}">

  <div class="geneInformation">

    <h3 class="overlapping">Genome Browser</h3>

    <p>Click and drag the browser to move the view.  Drag and drop tracks from left menu into the main
     panel to see the data. Clicking on individual features to open a report page for that feature.
      <br/>
      <strong>*</strong> denotes SNPs that are mapped to multiple genome position.
    <a id="jbrowseLink" href="" target="jbrowse">Centre on ${reportObject.object.primaryIdentifier}</a></p>
  <iframe id="jbrowseFrame" name="jbrowse" height="300px" width="98%" style="border: 1px solid #dfdfdf; padding: 1%" src=""></iframe>
    <p><a href="javascript:;" onclick="jQuery('iframe').css({height: '600px'});">Expand viewer</a>&nbsp;(more about <a href="https://jbrowse.org/jb2/">JBrowse</a>)</p>
</div>

</c:if>
<!-- /jBrowseDisplayer.jsp -->
