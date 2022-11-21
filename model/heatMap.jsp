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
java.util.Map<String,String> genePrimaryIDMap = (java.util.Map<String,String>) request.getAttribute("genePrimaryIDMap");

if (errorMessage!=null && errorMessage.length()>0) {
    out.print("<code>"+errorMessage+"</code>");
    return;
}

// no expression
if (sourceList==null || sourceList.size()==0) {
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

<div id="divToggle" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white; border:1px solid white; margin-top:10px;">
    Click here to toggle visibility of the expression heat map(s).
</div>
<div id="bigDiv" style="border:1px solid gray; padding:0 0 10px 10px;">
    <div style="padding:5px 0">
        <select id="expSelect" onChange="setExpressionSet(document.getElementById('expSelect').value)">
            <option value="-1">--- Select an expression study to see a heat map for these genes</h3> ---</option>
            <% for (int i=0; i<sources.length; i++) { %>
                <option value="<%=i%>"><%=sources[i]%>: <%=sampleCounts[i]%> samples, <%=geneCounts[i]%> genes</option>
            <% } %>
        </select>
    </div>
    <h3 id="sourceHeading"></h3>
    <div id="sourceSynopsis" style="font-weight:bold"></div>
    <div id="sourceUnit"></div>
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
 // constants
 const min_cluster = 5;
 const width_per_sample = 50;
 const height_per_gene = 50;

 // HTTP request objects
 const expressionJSON = ${expressionJSON};
 const sourcesJSON = ${sourcesJSON};
 const descriptionsJSON = ${descriptionsJSON};
 const namesJSON = ${namesJSON};
 const geneCounts = ${geneCounts};
 const sampleCounts = ${sampleCounts};
 
 // web.properties settings
 const showOverlays = ${WEB_PROPERTIES['heatmap.showOverlays']};
 const smpLabelScaleFontFactor = ${WEB_PROPERTIES['heatmap.smpLabelScaleFontFactor']};
 const smpLabelFontStyle = "${WEB_PROPERTIES['heatmap.smpLabelFontStyle']}";
 const smpLabelFontColor = "${WEB_PROPERTIES['heatmap.smpLabelFontColor']}";
 const varLabelScaleFontFactor = ${WEB_PROPERTIES['heatmap.varLabelScaleFontFactor']};
 const varLabelFontStyle = "${WEB_PROPERTIES['heatmap.varLabelFontStyle']}";
 const varLabelFontColor = "${WEB_PROPERTIES['heatmap.varLabelFontColor']}";
 const varLabelRotate = ${WEB_PROPERTIES['heatmap.varLabelRotate']};
 const varTitle = "Mouse over sample for description";
 const heatmapIndicatorPosition = "top";
 const heatmapIndicatorHistogram = ${WEB_PROPERTIES['heatmap.heatmapIndicatorHistogram']};
 const heatmapIndicatorHeight = ${WEB_PROPERTIES['heatmap.heatmapIndicatorHeight']};
 const heatmapIndicatorWidth = ${WEB_PROPERTIES['heatmap.heatmapIndicatorWidth']};

 // the map of gene secondaryIdentifier -> primaryIdentifier for gene links
 const genePrimaryIDMap = new Map();
 <% for (String key : genePrimaryIDMap.keySet()) { %>
 genePrimaryIDMap.set('<%=key%>', '<%=genePrimaryIDMap.get(key)%>');
 <% } %>
 
 // the (static) CanvasXpress configuration
 const conf = {
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
     if (index == -1) return;
     // grab the source metadata and expression data
     const source = sourcesJSON[index];
     const data = expressionJSON[index];
     const descriptions = descriptionsJSON[index];
     const names = namesJSON[index];
     const samplesKmeaned = (geneCounts[index]>=min_cluster);
     const variablesKmeaned = (sampleCounts[index]>=min_cluster);

     // the CanvasXpress event handlers - depends on names, source, descriptions
     // 
     // NOTE: do not put comments inside functions!
     // NOTE: gene click link generates a FAIR URI using the Gene.primaryIdentifier.
     // Example: window.open("/medicmine/gene:medtr.R108.gnm1.ann1.Medtr0002s0420");
     const evts = {
         "mousemove": function(o, e, t) {
             if (o.y.vars.length==1 && o.y.smps.length==1) {
                 const value = o.y.data[0][0]+" "+source.unit;
                 t.showInfoSpan(e, value);
             } else if (o.y.vars.length==1) {
                 const sample = o.y.vars[0];
                 const s = names[sample] + ":" + descriptions[sample];
                 t.showInfoSpan(e, s);
             } else if (o.y.smps.length==1) {
                 const gene = o.y.smps[0];
                 const url = "/${WEB_PROPERTIES['webapp.path']}/gene:"+genePrimaryIDMap.get(gene);
                 t.showInfoSpan(e, "go to "+gene+" gene page");
             }
         },
         "mouseout": function(o, e, t) {
         },
         "click": function(o, e, t) {
             if (o.y.smps.length==1) {
                 const gene = o.y.smps[0];
                 const url = "/${WEB_PROPERTIES['webapp.path']}/gene:"+genePrimaryIDMap.get(gene);
                 window.open(url);
             }
         },
         "dblclick": function(o, e, t) {
         }
     }

     // update the blurbs
     document.getElementById('sourceHeading').innerHTML = '<a href="report.do?id='+source.id+'">'+source.primaryIdentifier+'</a>';
     document.getElementById('sourceSynopsis').innerHTML = source.synopsis;
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

     // create/update the CanvasXpress object
     const cx = CanvasXpress.$('canvasx');
     if (cx==null) {
         // first one
         cx = new CanvasXpress('canvasx', data, conf, evts);
     } else {
         // replace the data
         cx.updateData(data);
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

 // big div visibility toggle
 jQuery("#divToggle").click(function () {
     jQuery("#bigDiv").toggle("slow");
 });
</script>
<!-- /heatMap.jsp -->
