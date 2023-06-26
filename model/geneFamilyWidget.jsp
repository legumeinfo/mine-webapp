<!-- geneFamilyWidget.jsp -->
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

// server-side constants
int WIDTH = 1200;
int HEIGHT = 800;

// non-JSON objects
java.util.Map<String,String> gfDescriptionMap = (java.util.Map) request.getAttribute("gfDescriptionMap");
%>

<h3>Gene family average gene counts per annotation by species</h3>

<div style="margin:10px auto;">
  Gene Family K-means:
  <select id="smps-km">
    <option value="2" selected>2</option>
    <option value="3">3</option>
    <option value="4">4</option>
    <option value="5">5</option>
  </select>
  Species K-means:
  <select id="vars-km">
    <option value="2" selected>2</option>
    <option value="3">3</option>
    <option value="4">4</option>
    <option value="5">5</option>
  </select>
</div>
    
<canvas id="canvasx" width="<%=WIDTH%>" height="<%=HEIGHT%>"></canvas>

<script type="text/javascript">

const gfDescriptionMap = new Map();
<% for (String key : gfDescriptionMap.keySet()) { %>
 gfDescriptionMap.set('<%=key%>', '<%=gfDescriptionMap.get(key)%>');
<% } %>

// the static CanvasXpress configuration
const conf = {
    'graphType': 'Heatmap',
    'canvasBox': true,

    'varTitle': 'Species',
    'smpTitle': 'Gene Family', 

    'varTitleScaleFontFactor': 1.0,
    'smpTitleScaleFontFactor': 1.0,
    
    'varLabelFontColor': "black",
    'smpLabelFontColor': "black",
    
    'varLabelRotate': 45, 
    'smpLabelRotate': -45,

    'varLabelScaleFontFactor': 0.4,
    'smpLabelScaleFontFactor': 0.4,

    'showHeatMapIndicator': true,
    'heatmapCellBox': true,
    'heatmapIndicatorPosition': 'top',
    'heatmapIndicatorHistogram': false,
    'heatmapIndicatorHeight': 25,
    'heatmapIndicatorWidth': 500,

    'samplesKmeaned': true,
    'variablesKmeaned': true,
    'kmeansSmpClusters': 2,
    'kmeansVarClusters': 2,

    'linkage': 'complete',
    'samplesClustered': false,
    'variablesClustered': false,
    'showSmpDendrogram': false,
    'showVarDendrogram': false,
}

// var=species, smp=gene family
const evts = {
    "mousemove": function(o, e, t) {
        if (o.y && o.y.vars.length==1 && o.y.smps.length==1) {
            // over cell
        } else if (o.y && o.y.smps.length==1) {
            // over gene family label
            const gf = o.y.smps[0];
            t.showInfoSpan(e, gfDescriptionMap.get(gf));
        } else if (o.y && o.y.vars.length==1) {
            // over species label
        }
    },
    "mouseout": function(o, e, t) {
    },
    "click": function(o, e, t) {
        if (o.y && o.y.vars.length==1 && o.y.smps.length==1) {
            // over cell
        } else if (o.y && o.y.smps.length==1) {
            // over gene family label
            const gf = o.y.smps[0];
            const url = "/${WEB_PROPERTIES['webapp.path']}/genefamily:" + gf
            window.open(url);
        } else if (o.y && o.y.vars.length==1) {
            // over species label
        }
    },
    "dblclick": function(o, e, t) {
    }
}
     
// create the CanvasXpress object
const cx = new CanvasXpress("canvasx", ${heatmapJSON}, conf, evts);

// respond to smps-km change (samples)
jQuery("#smps-km").change(
    function() {
        cx.kmeansSmpClusters = parseInt(this.value);
        cx.kmeansSamples(true);
   }
);
// respond to vars-km change (genes)
jQuery("#vars-km").change(
    function() {
        cx.kmeansVarClusters = parseInt(this.value);
        cx.kmeansVariables(true);
    }
);
</script>
<!-- /geneFamilyWidget.jsp -->
