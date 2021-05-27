<!-- heatMap.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<html:xhtml />
<tiles:importAttribute />
<%
// server-side variables
String errorMessage = (String) request.getAttribute("errorMessage");
java.util.List<String> sourceList = (java.util.List<String>) request.getAttribute("sources");
java.util.List<Integer> geneCountsList = (java.util.List<Integer>) request.getAttribute("geneCounts");
java.util.List<Integer> sampleCountsList = (java.util.List<Integer>) request.getAttribute("sampleCounts");

if (errorMessage==null) {
    out.print("<h2>errorMessage is null!</h2>");
    return;
} else if (errorMessage.length()>0) {
    out.print("<h2>"+errorMessage+"</h2>");
    return;
}

String[] sources = new String[sourceList.size()];
for (int i=0; i<sources.length; i++) {
    sources[i] = sourceList.get(i);    
}
int[] geneCounts = new int[geneCountsList.size()]; // they better be the same!
for (int i=0; i<geneCounts.length; i++) {
    geneCounts[i] = geneCountsList.get(i);
}
int[] sampleCounts = new int[sampleCountsList.size()]; // also should be the same!
for (int i=0; i<sampleCounts.length; i++) {
    sampleCounts[i] = sampleCountsList.get(i);
}
%>
<c:set var="height" value="${WEB_PROPERTIES['heatmap.height']}"/>
<c:set var="width" value="${WEB_PROPERTIES['heatmap.width']}"/>

<script type="text/javascript">
 // constants
 var min_cluster = 5;
 var width_per_sample = 50;
 var height_per_gene = 50;

 // HTTP request objects
 var expressionJSON = ${expressionJSON};
 var sourcesJSON = ${sourcesJSON};
 var descriptionsJSON = ${descriptionsJSON};
 var geneCounts = ${geneCounts};
 var sampleCounts = ${sampleCounts};
 
 // web.properties settings
 var showOverlays = ${WEB_PROPERTIES['heatmap.showOverlays']};
 var smpLabelScaleFontFactor = ${WEB_PROPERTIES['heatmap.smpLabelScaleFontFactor']};
 var smpLabelFontStyle = "${WEB_PROPERTIES['heatmap.smpLabelFontStyle']}";
 var smpLabelFontColor = "${WEB_PROPERTIES['heatmap.smpLabelFontColor']}";
 var varLabelScaleFontFactor = ${WEB_PROPERTIES['heatmap.varLabelScaleFontFactor']};
 var varLabelFontStyle = "${WEB_PROPERTIES['heatmap.varLabelFontStyle']}";
 var varLabelFontColor = "${WEB_PROPERTIES['heatmap.varLabelFontColor']}";
 var varLabelRotate = ${WEB_PROPERTIES['heatmap.varLabelRotate']};
 var varTitle = "Mouse over sample for description";
 var heatmapIndicatorPosition = "top";
 var heatmapIndicatorHistogram = ${WEB_PROPERTIES['heatmap.heatmapIndicatorHistogram']};
 var heatmapIndicatorHeight = ${WEB_PROPERTIES['heatmap.heatmapIndicatorHeight']};
 var heatmapIndicatorWidth = ${WEB_PROPERTIES['heatmap.heatmapIndicatorWidth']};
 
 // the (static) CanvasXpress configuration
 var conf = {
     "graphType": "Heatmap",
     "xAxisTitle": "",
     "canvasBox": false,
     "showHeatMapIndicator": true,
     "heatmapCellBox": true,
     "heatmapIndicatorPosition": heatmapIndicatorPosition,
     "heatmapIndicatorHistogram": heatmapIndicatorHistogram,
     "heatmapIndicatorHeight": heatmapIndicatorHeight,
     "heatmapIndicatorWidth": heatmapIndicatorWidth,
     "smpLabelScaleFontFactor": smpLabelScaleFontFactor,
     "smpLabelFontStyle": smpLabelFontStyle,
     "smpLabelFontColor": smpLabelFontColor,
     "varLabelScaleFontFactor": varLabelScaleFontFactor,
     "varLabelFontStyle": varLabelFontStyle,
     "varLabelFontColor": varLabelFontColor,
     "varLabelRotate": varLabelRotate,
     "varTitle": varTitle,
     "kmeansSmpClusters": 2,
     "kmeansVarClusters": 2,
     "linkage": "complete",
     "samplesClustered": false,
     "variablesClustered": false,
     "showSmpDendrogram": false,
     "showVarDendrogram": false,
     "showOverlays": showOverlays,
     "smpOverlayProperties": {
         "PCorr": {
             "thickness": 50,
             "position": "right",
             "type": "Dotplot",
             "color": "blue",
             "scheme": "User"
         }
     },
     "smpOverlays": [
         "PCorr"
     ]
 }
 
 // dynamically refresh the heatmap with the indicated expression set
 function setExpressionSet(index) {
     // grab the source metadata and expression data
     var source = sourcesJSON[index];
     var data = expressionJSON[index];
     var descriptions = descriptionsJSON[index];
     var samplesKmeaned = (geneCounts[index]>=min_cluster);
     var variablesKmeaned = (sampleCounts[index]>=min_cluster);
     // update the blurbs
     document.getElementById('sourceHeading').innerHTML = '<a href="report.do?id='+source.id+'">'+source.primaryIdentifier+'</a>';
     document.getElementById('sourceUnit').innerHTML = 'Expression unit: '+source.unit;
     if (showOverlays) {
         document.getElementById('sourceUnit').innerHTML += '; PCorr = mean Pearson correlation between that gene and the others.';
     }
     if (samplesKmeaned) {
         document.getElementById('geneClusteringBlurb').innerHTML = '';
     } else {
         document.getElementById('geneClusteringBlurb').innerHTML = 'Gene clustering is not available for fewer than '+min_cluster+' genes.';
     }
     if (variablesKmeaned) {
         document.getElementById('sampleClusteringBlurb').innerHTML = '';
     } else {
         document.getElementById('sampleClusteringBlurb').innerHTML = 'Sample clustering is not available for fewer than '+min_cluster+' samples.';
     }
     // the CanvasXpress event handlers
     // window.open("/${WEB_PROPERTIES['webapp.path']}/loadQuery.do?skipBuilder=true&query="+encodedQuery+"%0A++++++++++++&trail=|query&method=xml");
     var evts = {
	 "click": function(o, e, t) {
             var gene = o.y.smps[0];
             var sample = o.y.vars[0];
             var s = descriptions[sample];
             t.showInfoSpan(e, s);
	 }
     }
     // create/update the CanvasXpress object
     var cx = CanvasXpress.$('canvasx');
     if (cx==null) {
         // first one
         cx = new CanvasXpress('canvasx', data, conf, evts);
     } else {
         // replace the data
         cx.updateData(data);
         // update the k-means back to default
         cx.kmeansSmpClusters = 2;
         cx.kmeansVarClusters = 2;
         jQuery("#smps-km").val("2");
         jQuery("#vars-km").val("2");
     }
     // show k-means on features if enabled
     if (samplesKmeaned) {
         cx.kmeansSamples(true);
         jQuery("#smps-km").attr('disabled', false);
     } else {
         cx.kmeansSamples(false);
         jQuery("#smps-km").attr('disabled', true);
     }
     // show k-means on samples if enabled
     if (variablesKmeaned) {
         cx.kmeansVariables(true);
         jQuery("#vars-km").attr('disabled', false);
     } else {
         cx.kmeansVariables(false);
         jQuery("#vars-km").attr('disabled', true);
     }
     // respond to smps-km change (genes)
     jQuery("#smps-km").change(
         function() {
             cx.kmeansSmpClusters = parseInt(this.value);
             cx.kmeansSamples(true);
         }
     );
     // respond to vars-km change (samples)
     jQuery("#vars-km").change(
         function() {
             cx.kmeansVarClusters = parseInt(this.value);
             cx.kmeansVariables(true);
         }
     );
 }
</script>

<div id="divToggle" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white; border:1px solid white; margin-top:10px;">
    Click here to toggle visibility of the expression heat map(s).
</div>

<div id="bigDiv" style="border:1px solid gray; padding:0 0 10px 10px;">

    <div style="padding:5px 0">
        <h3>Select an expression set heat map for these genes:</h3>
        <select id="expSelect" onChange="setExpressionSet(document.getElementById('expSelect').selectedIndex);">
            <% for (int i=0; i<sources.length; i++) { %>
                <option <% if (i==0) out.print("selected"); %> ><%=sources[i]%>: <%=sampleCounts[i]%> samples, <%=geneCounts[i]%> genes</option>
            <% } %>
        </select>
    </div>

    <h3 id="sourceHeading"></h3>
    <div style="color:black;" id="sourceUnit"></div>
    
    <canvas id="canvasx" width="${width}" height="${height}"></canvas>
    <div style="width:400px; margin:5px auto; text-align:center; padding:5px; background-color:lightgray;">
        <p id="geneClusteringBlurb" style="font-style:italic"></p>
        <p id="sampleClusteringBlurb" style="font-style:italic"></p>
        Gene K-means:
        <select id="smps-km">
            <option value="2" selected>2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
        </select>
        Sample K-means:
        <select id="vars-km">
            <option value="2" selected>2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
        </select>
    </div>
</div>

<script type="text/javascript">
 // initialize the canvas with the first expression set
 setExpressionSet(0);
 
 // big div visibility toggle
 jQuery("#divToggle").click(function () {
     jQuery("#bigDiv").toggle("slow");
 } );
</script>
<!-- /heatMap.jsp -->
