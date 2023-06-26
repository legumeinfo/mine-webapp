<!-- heatMap.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<html:xhtml />
<tiles:importAttribute />
<%
// bail on error
if (request.getAttribute("errorMessage")!=null) {
    out.print("<code>"+request.getAttribute("errorMessage")+"</code>");
    return;
}

// non-JSON objects
java.util.List<String> sourceList = (java.util.List<String>) request.getAttribute("sources");
java.util.Map<String,String> genePrimaryIDMap = (java.util.Map<String,String>) request.getAttribute("genePrimaryIDMap");
java.util.Map<String,String> geneDescriptionMap = (java.util.Map<String,String>) request.getAttribute("geneDescriptionMap");

// bail if no sources
if (sourceList==null || sourceList.size()==0) {
    return;
}

// server-side constants
int WIDTH=1200;
int HEIGHT=800;
%>

<c:if test="${WEB_PROPERTIES['heatmap.debug'] == 'true'}">
    <h3>expressionJSON</h3>
    <code>
        ${expressionJSON}
    </code>
    <h3>sourcesJSON</h3>
    <code>
        ${sourcesJSON}
    </code>
    <h3>descriptionsJSON</h3>
    <code>
        ${descriptionsJSON}
    </code>
</c:if>

<h3>Expression Heat Maps (click to toggle)</h3>
<% for (int i=0; i<sourceList.size(); i++) { %>
    <div style="clear:both; padding-top:5px;">
        <a id="title<%=i%>" style="font-weight:bold;" href="javascript:void(0);"></a>
    </div>
    <div id="div<%=i%>" style="clear:both; display:none; block-size:fit-content;">
        <p id="synopsis<%=i%>" style="font-weight:bold"></p>
        <p id="unit<%=i%>"></p>
        <div style="margin:10px auto;">
            Sample K-means:
            <select id="smps-km<%=i%>">
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
            </select>
            Gene K-means:
            <select id="vars-km<%=i%>">
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
            </select>
        </div>
        <canvas id="canvasx<%=i%>" width="<%=WIDTH%>" height="<%=HEIGHT%>"></canvas>
    </div>
    <script type="text/javascript">
        jQuery("#title<%=i%>").click(function() {
            jQuery("#div<%=i%>").toggle("slow");
        });
    </script>
<% } %>

<script type="text/javascript">
 // config properties
 const heatmapIndicatorHeight = 50;
 const heatmapIndicatorWidth = 500;
 const varLabelScaleFontFactor = 1.2;
 const varLabelFontColor = "black";
 const varLabelRotate = 45;
 const varTitleScaleFontFactor = 1.0;
 const smpLabelScaleFontFactor = 1.2;
 const smpLabelFontColor = "black";
 const smpLabelRotate = -45;
 const smpTitleScaleFontFactor = 0.5;

 // other constants
 const min_cluster = 5;
 const width_per_sample = 50;
 const height_per_gene = 50;
 
 // HTTP request JSON strings
 const expressionJSON = ${expressionJSON};
 const sourcesJSON = ${sourcesJSON};
 const descriptionsJSON = ${descriptionsJSON};
 
 // the maps of gene name -> primaryIdentifier, description for rollover and gene links
 const genePrimaryIDMap = new Map();
 const geneDescriptionMap = new Map();
 <% for (String key : genePrimaryIDMap.keySet()) { %>
 genePrimaryIDMap.set('<%=key%>', '<%=genePrimaryIDMap.get(key)%>');
 geneDescriptionMap.set('<%=key%>', '<%=geneDescriptionMap.get(key)%>');
 <% } %>
 
 // the static CanvasXpress configuration
 const conf = {
     'graphType': 'Heatmap',
     'smpTitle': 'Mouse over sample for description.',
     'varTitle': 'Mouse over gene for description; click to go to gene page.',
     'canvasBox': true,
     'showHeatMapIndicator': true,
     'heatmapCellBox': true,
     'heatmapIndicatorPosition': 'top',
     'heatmapIndicatorHistogram': false,
     'heatmapIndicatorHeight': heatmapIndicatorHeight,
     'heatmapIndicatorWidth': heatmapIndicatorWidth,
     'varLabelScaleFontFactor': varLabelScaleFontFactor,
     'varLabelFontColor': varLabelFontColor,
     'varLabelRotate': varLabelRotate,
     'varTitleScaleFontFactor': varTitleScaleFontFactor,
     'smpLabelScaleFontFactor': smpLabelScaleFontFactor,
     'smpLabelFontColor': smpLabelFontColor,
     'smpLabelRotate': smpLabelRotate,
     'smpTitleScaleFontFactor': smpTitleScaleFontFactor,
     'kmeansSmpClusters': 2,
     'kmeansVarClusters': 2,
     'linkage': 'complete',
     'samplesClustered': false,
     'variablesClustered': false,
     'showSmpDendrogram': false,
     'showVarDendrogram': false,
 }

 for (var index=0; index<sourcesJSON.length; index++) {
     // the div ids
     const titleId = 'title'+index;
     const synopsisId = 'synopsis'+index;
     const unitId = 'unit'+index;
     const canvasId = 'canvasx'+index;
     const smpskmId = '#smps-km'+index;
     const varskmId = '#vars-km'+index;

     // grab the source metadata and expression data
     const source = sourcesJSON[index];
     const data = expressionJSON[index];
     const descriptions = descriptionsJSON[index];

     const samplesKmeaned = (source.sampleCount >= min_cluster);
     const variablesKmeaned = (source.geneCount >= min_cluster);
          
     const evts = {
         "mousemove": function(o, e, t) {
             if (o.y && o.y.vars.length==1 && o.y.smps.length==1) {
                 const value = o.y.data[0][0]+" "+source.unit;
                 t.showInfoSpan(e, value);
             } else if (o.y && o.y.smps.length==1) {
                 const sample = o.y.smps[0];
                 const s = descriptions[sample];
                 t.showInfoSpan(e, s);
             } else if (o.y && o.y.vars.length==1) {
                 const gene = o.y.vars[0];
                 t.showInfoSpan(e, geneDescriptionMap.get(gene));
             }
         },
         "mouseout": function(o, e, t) {
         },
         "click": function(o, e, t) {
             if (o.y && o.y.vars.length==1) {
                 const gene = o.y.vars[0];
                 const url = "/${WEB_PROPERTIES['webapp.path']}/gene:"+genePrimaryIDMap.get(gene);
                 window.open(url);
             }
         },
         "dblclick": function(o, e, t) {
         }
     }
     
     // create the CanvasXpress object
     const cx = new CanvasXpress(canvasId, data, conf, evts);

     // populate the metadata above the canvas
     document.getElementById(titleId).innerHTML = source.primaryIdentifier+": "+source.sampleCount+ " samples, "+source.geneCount+" genes";
     document.getElementById(synopsisId).innerHTML = source.synopsis;
     document.getElementById(unitId).innerHTML = "Units: "+source.unit;
     
     // toggle on k-means on samples if enabled
     if (samplesKmeaned) {
         cx.kmeansSamples(true);
         cx.kmeansSmpClusters = 2;
         jQuery(smpskmId).attr('disabled', false);
         jQuery(smpskmId).val("2");
     } else {
         jQuery(smpskmId).attr('disabled', true);
     }
     // toggle on k-means on genes if enabled
     if (variablesKmeaned) {
         cx.kmeansVariables(true);
         cx.kmeansVarClusters = 2;
         jQuery(varskmId).attr('disabled', false);
         jQuery(varskmId).val("2");
     } else {
         jQuery(varskmId).attr('disabled', true);
     }
     
     // respond to smps-km change (samples)
     jQuery(smpskmId).change(
         function() {
             cx.kmeansSmpClusters = parseInt(this.value);
             cx.kmeansSamples(true);
         }
     );
     // respond to vars-km change (genes)
     jQuery(varskmId).change(
         function() {
             cx.kmeansVarClusters = parseInt(this.value);
             cx.kmeansVariables(true);
         }
     );
 }
</script>
<!-- /heatMap.jsp -->
