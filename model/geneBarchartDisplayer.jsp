<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- geneBarchartDisplayer.jsp -->
<html:xhtml />
<tiles:importAttribute />

<!-- static canvasXpress configuration -->
<script type="text/javascript">
 var conf = {
     "axisAlgorithm": "wilkinson",
     "graphOrientation": "vertical",
     "marginTop": 100,
     "axisMinMaxTickTickWidth": false,
     "axisTickScaleFontFactor": 1,
     "axisTitleScaleFontFactor": 1.0,
     "smpLabelRotate": 45,
     "smpTitleFontStyle": "italic",
     "smpTitleScaleFontFactor": 0.5,
     "smpTitle": "Mouse over bar for full sample description",
     "showLegend": false
 }
</script>

<!-- loop over the sources -->
<c:set var="index" value="0" scope="page"/>
<c:set var="sourcesExist" value="false" scope="page"/>
<c:forEach items="${sourcesJSON}" var="sourceJSON">
    <c:set var="sourcesExist" value="true" scope="page"/>

    <h3 id="sourceIdentifier${index}"></h3>
    <div id="sourceSynopsis${index}"></div>
    <canvas id="canvasx${index}" width="${WEB_PROPERTIES['geneBarchartDisplayer.width']}" height="${WEB_PROPERTIES['geneBarchartDisplayer.height']}"></canvas>

    <script type="text/javascript">
     const sourceJSON = ${sourceJSON};
     const genotypesJSON${index} = ${genotypesList[index]};
     const tissuesJSON${index} = ${tissuesList[index]};
     const treatmentsJSON${index} = ${treatmentsList[index]};
     const descriptionsJSON${index} = ${descriptionsList[index]};

     // link the expression source
     document.getElementById('sourceIdentifier${index}').innerHTML = '<a href="report.do?id='+sourceJSON.id+'">'+sourceJSON.identifier+'</a>';
     // display the source synopsis
     document.getElementById('sourceSynopsis${index}').innerHTML = sourceJSON.synopsis;
     
     // the data for this source - global scope required
     const data = ${jsonList[index]};
     
     // the CanvasXpress event handlers - global scope required
     const evts = {
         mousemove: function(o, e, t) {
             const sample = o.y.smps;
             const genotype = String(genotypesJSON${index}[sample]);
             const tissue = String(tissuesJSON${index}[sample]);
             const treatment = String(treatmentsJSON${index}[sample]);
             const description = String(descriptionsJSON${index}[sample]);
             let s = sample;
             if (genotype!="undefined") s += ":" + genotype;
             if (tissue!="undefined") s += ":" + tissue;
             if (treatment!="undefined") s += ":" + treatment;
             if (description!="undefined") s += ":" + description;
             t.showInfoSpan(e, s);
         }
     }

     // put this source's expression unit on the x axis
     conf["xAxisTitle"] = "${unitsList[index]}";
     
     // load the canvas
     const cx${index} = new CanvasXpress("canvasx${index}", data, conf, evts);
    </script>

    <c:set var="index" value="${index+1}" scope="page"/>
    <div class="clear"></div>
</c:forEach>

<c:if test="${sourcesExist=='false'}">
    <h3>No expression data is present for this gene.</h3>
</c:if>
<!-- /geneBarchartDisplayer.jsp -->
