<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- geneHeatmapDisplayer.jsp -->
<html:xhtml />
<tiles:importAttribute />

<!-- loop over the sources -->
<c:set var="index" value="0" scope="page"/>
<c:forEach items="${sourcesJSON}" var="sourceJSON">

    <h3 id="sourceIdentifier${index}"></h3>
    <p id="sourceDescription${index}"></p>

    <script type="text/javascript">
     var sourceJSON = ${sourceJSON};
     document.getElementById('sourceIdentifier${index}').innerHTML = sourceJSON.identifier;
     document.getElementById('sourceDescription${index}').innerHTML = sourceJSON.description;
    </script>

    <canvas id="canvasx${index}" width="${WEB_PROPERTIES['geneHeatmapDisplayer.width']}" height="${WEB_PROPERTIES['geneHeatmapDisplayer.height']}"></canvas>
    <script type="text/javascript">
     var cx${index} = new CanvasXpress("canvasx${index}",
                                       ${jsonList[index]},
                                       {
                                           "graphType": "Heatmap",
                                           "title": "RNA-seq expression ("+sourceJSON.unit+")",
                                           "xAxisTitle": null,
                                           "titleScaleFontFactor": ${WEB_PROPERTIES['geneHeatmapDisplayer.titleScaleFontFactor']},
                                           "legendScaleFontFactor": ${WEB_PROPERTIES['geneHeatmapDisplayer.legendScaleFontFactor']},
                                           "isLogData": ${WEB_PROPERTIES['heatmap.isLogData']},
                                           "smpLabelScaleFontFactor": ${WEB_PROPERTIES['geneHeatmapDisplayer.smpLabelScaleFontFactor']},
                                           "smpLabelFontStyle": "${WEB_PROPERTIES['geneHeatmapDisplayer.smpLabelFontStyle']}",
                                           "smpLabelFontColor": "${WEB_PROPERTIES['geneHeatmapDisplayer.smpLabelFontColor']}",
                                           "varLabelScaleFontFactor": ${WEB_PROPERTIES['geneHeatmapDisplayer.varLabelScaleFontFactor']},
                                           "varLabelFontStyle": "${WEB_PROPERTIES['geneHeatmapDisplayer.varLabelFontStyle']}",
                                           "varLabelFontColor": "${WEB_PROPERTIES['geneHeatmapDisplayer.varLabelFontColor']}",
                                           "varLabelRotate": ${WEB_PROPERTIES['geneHeatmapDisplayer.varLabelRotate']},
                                           "colorSpectrum": [ ${WEB_PROPERTIES['heatmap.colorSpectrum']} ],
                                           "colorSpectrumBreaks": [ ${WEB_PROPERTIES['heatmap.colorSpectrumBreaks']} ],
                                           "heatmapIndicatorPosition": "${WEB_PROPERTIES['geneHeatmapDisplayer.heatmapIndicatorPosition']}",
                                           "heatmapIndicatorHistogram": ${WEB_PROPERTIES['geneHeatmapDisplayer.heatmapIndicatorHistogram']},
                                           "heatmapIndicatorWidth": ${WEB_PROPERTIES['geneHeatmapDisplayer.heatmapIndicatorWidth']},
                                           "heatmapIndicatorHeight": ${WEB_PROPERTIES['geneHeatmapDisplayer.heatmapIndicatorHeight']},
                                           "adjustAspectRatio": true,
                                           "adjustAspectRatioHeatmapIndicator": false,
                                           "canvasBox": true,
                                           "heatmapCellBox": true,
                                           "heatmapCellBox": true,
                                           "showHeatMapIndicator": true,
                                           "samplesKmeaned": false,
                                           "variablesKmeaned": false,
                                           "samplesClustered": false,
                                           "variablesClustered": false,
                                           "showSmpDendrogram": false,
                                           "showVarDendrogram": false
                                       },
                                       {
                                           click: function(o) {
                                               var featureId = o.y.smps;
                                               var condition = o.y.vars;
                                               if (featureId.length==1 && condition.length==1) {
                                                   var query = '<query name="" model="genomic" view="ExpressionValue.feature.primaryIdentifier ExpressionValue.sample.num ExpressionValue.sample.primaryIdentifier ExpressionValue.sample.description ExpressionValue.value" sortOrder="ExpressionValue.sample.num asc"><constraint path="ExpressionValue.sample.primaryIdentifier" op="=" value="'+condition+'"/><constraint path="ExpressionValue.feature.primaryIdentifier" op="=" value="'+featureId+'"/></query>';
                                                   var encodedQuery = encodeURIComponent(query);
                                                   encodedQuery = encodedQuery.replace("%20", "+");
                                                   window.open("/${WEB_PROPERTIES['webapp.path']}/loadQuery.do?skipBuilder=true&query="+encodedQuery+"%0A++++++++++++&trail=|query&method=xml");
                                               }
                                           }
                                       }
     );
    </script>

    <c:set var="index" value="${index+1}" scope="page"/>
    <div class="clear"></div>
</c:forEach>
<!-- /geneHeatmapDisplayer.jsp -->
