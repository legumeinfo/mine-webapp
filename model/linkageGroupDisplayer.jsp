<!-- linkageGroupDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<html:xhtml />
<tiles:importAttribute />
<c:if test="${(tracksJSON.length()>20)}">
    <canvas id="canvasx" width="${WEB_PROPERTIES['linkageGroupDiagram.width']}"></canvas>
    <script type="text/javascript">
     var cx = new CanvasXpress("canvasx",
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
                                       var id = o[0].data[0].key;
                                       if (id!=null) window.open("report.do?id="+id, '_self', false);
                                   }
                               }
     );
    </script>
    <br clear="all"/>
</c:if>
<!-- /linkageGroupDisplayer.jsp -->
