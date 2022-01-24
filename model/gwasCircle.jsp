<!-- gwasCircle.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder,java.util.List" language="java" %>
<html:xhtml />
<tiles:importAttribute />
<c:set var="width" value="${WEB_PROPERTIES['gwasCircle.width']}"/>
<c:set var="height" value="${WEB_PROPERTIES['gwasCircle.height']}"/>
<%
// request data from GWASCircle
List<String> markerList = (List<String>) request.getAttribute("markerList");
List<String> chromosomeList = (List<String>) request.getAttribute("chromosomeList");
List<String> traitList = (List<String>) request.getAttribute("traitList");
List<Double> positionList = (List<Double>) request.getAttribute("positionList");
List<Double> log10pList = (List<Double>) request.getAttribute("log10pList");
// create quoted lists for Javascript below
String markerString = "";
for (String marker : markerList) {
    if (markerString.length()>0) markerString += ",";
    markerString += "\""+marker+"\"";
}
String chromosomeString = "";
for (String chromosome : chromosomeList) {
    if (chromosomeString.length()>0) chromosomeString += ",";
    chromosomeString += "\""+chromosome+"\"";
}
String traitString = "";
for (String trait : traitList) {
    if (traitString.length()>0) traitString += ",";
    traitString += "\""+trait+"\"";
}
%>

<!-- <div>
     var chromosome = [<%=chromosomeString%>];
     </div>
     <div>
     var trait = [<%=traitString%>];
     </div>
     <div>
     var marker = [<%=markerString%>];
     </div>
     <div>
     var position = <%=positionList%>;
     </div>
     <div>
     var value = <%=log10pList%>;
     </div> -->
    
    <canvas id="canvasx" width="${width}" height="${height}"></canvas>
    <br clear="all"/>
    <script type="text/javascript">
     // the CanvasXpress event handlers    
     // var evts = {
     //     click: function(o) {
     //         var marker = o.y.vars;
     //  window.open("/${WEB_PROPERTIES['webapp.path']}/portal.do?class=GeneticMarker&externalids="+marker);
     //     }
     // }
     
     var chromosome = [<%=chromosomeString%>];
     var trait = [<%=traitString%>];
     var marker = [<%=markerString%>];
     var position = <%=positionList%>;
     var value = <%=log10pList%>;
     
     var data = {
         "x" : {
             "chromosome" : chromosome,
             "trait" : trait
         },
         "y" : {
             "vars" : ["Position", "Value"],
             "smps" : marker,
             "data" : [position, value]
         },
         "z" : {
             "ring" : ["", "1"]
         }
     }

     var config = {
         graphType : "Circular",
         showLegend: false,
         rAxis : "Position",
         rAxisPercentShow: false,
         rAxisZero: true,
         segregateSamplesBy : ["chromosome"],
         segregateVariablesBy : ["ring"],
         smpOverlays : [<%=traitString%>]
     }

     var cX = new CanvasXpress("canvasx", data, config);
    </script>
<!-- /gwasCircle.jsp -->
