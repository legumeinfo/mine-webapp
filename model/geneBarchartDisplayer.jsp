<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- geneBarchartDisplayer.jsp -->
<html:xhtml />
<tiles:importAttribute />

<!-- loop over the sources -->
<c:set var="index" value="0" scope="page"/>
<c:set var="sourcesExist" value="false" scope="page"/>
<c:forEach items="${sourcesJSON}" var="sourceJSON">
    <c:set var="sourcesExist" value="true" scope="page"/>

    <h3 id="sourceIdentifier${index}"></h3>
    
    <script type="text/javascript">
     var sourceJSON = ${sourceJSON};
     var descriptionsJSON${index} = ${descriptionsList[index]};
     var unit = "${unitsList[index]}";

     // link the expression source
     document.getElementById('sourceIdentifier${index}').innerHTML = '<a href="report.do?id='+sourceJSON.id+'">'+sourceJSON.identifier+'</a>';

     // the data for this source
     var data = ${jsonList[index]};

     // the CanvasXpress configuration
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
         "xAxisTitle": unit,
         "showLegend": false
     }

     // the CanvasXpress event handlers
     var evts = {
         mousemove: function(o, e, t) {
             var sample = o.y.smps;
             var s = sample+":"+descriptionsJSON${index}[sample];
             t.showInfoSpan(e, s);
         }
     }
    </script>

    <canvas id="canvasx${index}" width="${WEB_PROPERTIES['geneBarchartDisplayer.width']}" height="${WEB_PROPERTIES['geneBarchartDisplayer.height']}"></canvas>

    <script type="text/javascript">
     var cx${index} = new CanvasXpress("canvasx${index}", data, conf, evts);
    </script>

    <c:set var="index" value="${index+1}" scope="page"/>
    <div class="clear"></div>
</c:forEach>

<c:if test="${sourcesExist=='false'}">
    <h3>No expression data is present for this gene.</h3>
</c:if>
<!-- /geneBarchartDisplayer.jsp -->
