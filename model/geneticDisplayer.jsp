<!-- geneticDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<html:xhtml />
<tiles:importAttribute />

<c:if test="${WEB_PROPERTIES['geneticDisplayer.debug'] == 'true'}">
    <h3>tracksJSON</h3>
    <code>
        ${tracksJSON}
    </code>
</c:if>

<script type="text/javascript">
 var data = ${tracksJSON};
 var conf = {
     "graphType": "Genome",
     "backgroundType": "solid",
     "showShadow": false,
     "featureStaggered": true,
     "background": ${WEB_PROPERTIES['geneticDisplayer.background']},
     "fontName": ${WEB_PROPERTIES['geneticDisplayer.fontName']},
     "featureNameFontSize": ${WEB_PROPERTIES['geneticDisplayer.featureNameFontSize']},
     "featureNameFontColor": ${WEB_PROPERTIES['geneticDisplayer.featureNameFontColor']},
     "featureNameFontStyle": ${WEB_PROPERTIES['geneticDisplayer.featureNameFontStyle']},
     "featureHeightDefault": ${WEB_PROPERTIES['geneticDisplayer.featureHeightDefault']},
     "xAxisTickColor": ${WEB_PROPERTIES['geneticDisplayer.xAxisTickColor']},
     "wireColor": ${WEB_PROPERTIES['geneticDisplayer.wireColor']},
     "setMinX": 0,
     "setMaxX": ${maxLGLength}+5,
     "xAxisExact": false
 }
 var evts = {
     'click': function(o) {
         var id = o[0].data[0].key;
         if (id!=null) window.open("report.do?id="+id, '_self', false);
     }
 }
 var cx = new CanvasXpress("canvasx", data, conf, evts);
</script>
<canvas id="canvasx" width="${WEB_PROPERTIES['geneticDisplayer.width']}" height="${WEB_PROPERTIES['geneticDisplayer.height']}"></canvas>
<!-- this br is required to prevent a scrollbar on the report page -->
<br clear="all"/>
<!-- /geneticDisplayer.jsp -->
