<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>
<!-- motifSearch.jsp -->
<html:xhtml />
<tiles:importAttribute />
<%
// initialize
String errorMessage = null;
int MAX_MOTIF_LENGTH = 0;
int MAX_MOTIF_COUNT = 0;
double MAX_DISTANCE = 0.0;
int GOP = 0;
int GEP = 0;
String ALIGNER = null;
String featureType = null;
int featureCount = 0;
long blastTime = 0;
int logoMotifsCount = 0;
String logoURL = null;
String seqHitsJSON = null;
// sent over from MotifSearchController
if (request.getAttribute("errorMessage")!=null) errorMessage = (String) request.getAttribute("errorMessage");
if (request.getAttribute("MAX_MOTIF_LENGTH")!=null) MAX_MOTIF_LENGTH = (int) request.getAttribute("MAX_MOTIF_LENGTH");
if (request.getAttribute("MAX_MOTIF_COUNT")!=null) MAX_MOTIF_COUNT = (int) request.getAttribute("MAX_MOTIF_COUNT");
if (request.getAttribute("MAX_DISTANCE")!=null) MAX_DISTANCE = (double) request.getAttribute("MAX_DISTANCE");
if (request.getAttribute("GOP")!=null) GOP = (int) request.getAttribute("GOP");
if (request.getAttribute("GEP")!=null) GEP = (int) request.getAttribute("GEP");
if (request.getAttribute("ALIGNER")!=null) ALIGNER = (String) request.getAttribute("ALIGNER");
if (request.getAttribute("featureType")!=null) featureType = (String) request.getAttribute("featureType");
if (request.getAttribute("featureCount")!=null) featureCount = (int) request.getAttribute("featureCount");
if (request.getAttribute("blastTime")!=null) blastTime = (long) request.getAttribute("blastTime");
if (request.getAttribute("logoMotifsCount")!=null) logoMotifsCount = (int) request.getAttribute("logoMotifsCount");
if (request.getAttribute("logoURL")!=null) logoURL = (String) request.getAttribute("logoURL");
if (request.getAttribute("seqHitsJSON")!=null) seqHitsJSON = (String) request.getAttribute("seqHitsJSON");
%>
<% if (errorMessage!=null) { %>
    <div style="border:2px solid red; padding:10px">
        <%=errorMessage%>
    </div>
<% } else { %>
    
    <div id="motifSearch_toggle" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white;">
        Click to toggle Shared Motif Search <img src="images/disclosed.gif" id="motifToggle" />
    </div>
    
    <div id="motifSearch">

        <h3>Shared Motif Search</h3>

        <% if (logoURL!=null && logoURL.length()>0) { %>
            <div style="text-align:center">
                <b><%=logoMotifsCount%> motifs close to top scorer:</b><br/>
                <img src="<%=logoURL%>" alt="sequence logo"/>
            </div>
        <% } %>

        <table id="motifs" class="display" width="100%" cellspacing="0">
            <thead>
                <tr>
                    <th>Motif</th>
                    <th>Length</th>
                    <th>Num</th>
                    <th>Score</th>
                    <th>Regions</th>
                    <th></th>
                    <th>Hit</th>
                    <th>Perc</th>
                    <th>Jaspar</th>
                </tr>
            </thead>
        </table>

        <div id="description_div" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white;">
            More information <img src="images/undisclosed.gif" id="co">
        </div>
        
        <div id="description" style="padding:5px">
            <p style="margin:5px 0">
                The Shared Motif Search executes a BLAST+ run for each feature against the remaining features (if there are 10 features, there will be 10 1&times;9 BLAST runs).
                The BLAST results are then collated to find shared motifs. Only motifs which contain a C or G are included (there are always hundreds of shared motifs
                containing only A and T), and
                only motifs up to length <%=MAX_MOTIF_LENGTH%> are shown. The list is truncated at <%=MAX_MOTIF_COUNT%> motifs.
                The score is based on the number of features that contain the motif (shown in the Num column), the DNA content of the motif (C and G score
                higher than A and T), and the length of the motif (longer motifs score higher).
                The group of features that share a motif is linked so you can create a list. If the top-scoring motif has other motifs close to it
                (defined by a <%=ALIGNER%> pairwise alignment distance), a sequence logo is displayed on the top summarizing that group of motifs, which are marked with an asterisk.
                Those are included at the end of the list if they score below the top <%=MAX_MOTIF_COUNT%>. Put * in the Search: box to limit the list to only those motifs. 
            </p>
            <p style="margin:5px 0">
                Motifs that contribute to the sequence logo (if any) are searched against motifs of the same length in the JASPAR2018 binding-site database.
                The best hit is shown in the rightmost three columns, with a link to the corresponding JASPAR page.
            </p>
            <p style="margin:5px 0">
                To investigate a particular motif further, use a tool like <a href="http://meme-suite.org/tools/gomo" target="_blank">GOMo</a> in the MEME Suite,
                which scans it for associated GO terms for a chosen species.
                Or, for example, look it up in a transcription factor binding sites list,
                like <a href="http://arabidopsis.med.ohio-state.edu/AtcisDB/bindingsites.html">AGRIS</a> for Arabidopsis.
                If you're interested in a particular motif, just type it in the search box to filter the results.
            </p>
            <p style="margin:4px 0">
                1.<i>BLAST: A greedy algorithm for aligning DNA sequences</i> Zheng Zhang, Scott Schwartz, Lukas Wagner and Webb Miller, J. Comput. Biol. 7, 203 (2000).
            </p>
            <p style="margin:4px 0">
                2.<i>BLAST+: architecture and applications</i> Camacho C., Coulouris G., Avagyan V., Ma N., Papadopoulos J., Bealer K., & Madden T.L., BMC Bioinformatics 10, 421 (2008).
            </p>
            <p style="margin:4px 0">
                3.<i>BioJava: an open-source framework for bioinformatics</i> Andreas Prlic, Andrew Yates, Spencer E. Bliven, Peter W. Rose, Julius Jacobsen, Peter V. Troshin,
                Mark Chapman, Jianjiong Gao, Chuan Hock Koh, Sylvain Foisy, Richard Holland, Gediminas Rimsa, Michael L. Heuer, H. Brandstatter-Muller, Philip E. Bourne,
                Scooter Willis, Bioinformatics 28, 2693 (2012).
            </p>
            <p style="margin:4px 0">
                4.<i>WebLogo: A sequence logo generator</i> Crooks GE, Hon G, Chandonia JM, Brenner SE, Genome Research 14, 1188 (2004).
            </p>
            <p style="margin:4px 0">
                5.<i>JASPAR 2018: update of the open-access database of transcription factor binding profiles and its web framework</i>
                Khan, A. et al., Nucleic Acids Res. 46, D260–D266 (2018).
            </p>
        </div>

    </div>

    <script type="text/javascript">
     var seqHitsObject = JSON.parse('<%=seqHitsJSON%>');

     $(document).ready(function() {
         
         var table = $('#motifs').dataTable( {
             order: [[3,'desc']],
             columns: [
                 { data: "sequence" },
                 { data: "length", className: "dt-right" },
                 { data: "num",   className: "dt-right" },
                 { data: "score",  className: "dt-right" },
                 { data: "regions", orderable: false,
                   "render": function (data, type, full, meta) {
                       return data.toString().replace(/,/g,"<br/>");
                   }
                 },
                 { data: "ids", searchable: false, orderable: false,
                   "render": function(data, type, full, meta) {
                       return '<a href="buildBag.do?type=${featureType}&text=&quot;' + data.toString().replace(/,/g,"&quot;,&quot;") + '&quot;">List</a>';
                   }
                 }, 
                 { data: "bestHitName", className: "dt-right" },
                 { data: "bestHitScore", className: "dt-right" },
                 { data: "bestHitBaseId", orderable:false,
                   "render": function(data, type, full, meta) {
                       return '<a target="_blank" href="http://jaspar.genereg.net/matrix/' + data + '">' + data + '</a>';
                   }
                 }
             ],
             data: seqHitsObject.data
         } );
     } );
     
     $("#motifSearch_toggle").click(function () {
         if ($("#motifSearch").is(":hidden")) {
             $("#motifToggle").attr("src", "images/disclosed.gif");
         } else {
             $("#motifToggle").attr("src", "images/undisclosed.gif");
         }
         $("#motifSearch").toggle("slow");
     } );
     
     $("#description").hide();

     $("#description_div").click(
         function () {
             if ($("#description").is(":hidden")) {
                 $("#co").attr("src", "images/disclosed.gif");
             } else {
                 $("#co").attr("src", "images/undisclosed.gif");
             }
             $("#description").toggle("slow");
         }
     );
    </script>
<% } %>
<!-- /motifSearch.jsp -->
