<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- linkageGroupDiagram.jsp -->
<html:xhtml />
<tiles:importAttribute />
<c:set var="width" value="${WEB_PROPERTIES['linkageGroupDiagram.width']}"/>
<c:set var="height" value="${WEB_PROPERTIES['linkageGroupDiagram.height']}"/>
<script type="text/javascript">
 var cx = new CanvasXpress("canvasID",
                           ${tracksJSON}, 
                           {
                               "graphType": "Genome",
                               "backgroundType": "solid",
                               "showShadow": false,
                               "featureStaggered": true,
                               "background": ${WEB_PROPERTIES['linkageGroupDiagram.background']},
                               "fontName": ${WEB_PROPERTIES['linkageGroupDiagram.fontName']},
                               "featureNameFontSize": ${WEB_PROPERTIES['linkageGroupDiagram.featureNameFontSize']},
                               "featureNameFontColor": ${WEB_PROPERTIES['linkageGroupDiagram.featureNameFontColor']},
                               "featureNameFontStyle": ${WEB_PROPERTIES['linkageGroupDiagram.featureNameFontStyle']},
                               "featureHeightDefault": ${WEB_PROPERTIES['linkageGroupDiagram.featureHeightDefault']},
                               "xAxisTickColor": ${WEB_PROPERTIES['linkageGroupDiagram.xAxisTickColor']},
                               "wireColor": ${WEB_PROPERTIES['linkageGroupDiagram.wireColor']},
                               "setMinX": 0,
                               "setMaxX": ${maxLGLength}+5,
                               "xAxisExact": false
                           },
                           {
                               'click': function(o) {
                                   var featureId = o[0].data[0].key;
                                   window.open("report.do?id="+featureId, '_self', false);
                               }
                           }
     
 );
</script>
<canvas id="canvasID" width="${width}" height="${height}"></canvas>
<br clear="all"/>
<!-- /linkageGroupDiagram.jsp -->
