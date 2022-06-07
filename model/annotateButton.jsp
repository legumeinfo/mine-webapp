<%@ page import="org.biojava.nbio.core.sequence.io.FastaWriterHelper" %>
<%@ page import="org.ncgr.intermine.web.logic.SequenceAnnotateUtil" %>
<%
try {
    // Display the ANNOTATE button to send the sequence to the annotate URL
    Integer objectId = Integer.parseInt(request.getParameter("id"));
    // create the FASTA using SequenceAnnotateUtil
    SequenceAnnotateUtil sequenceAnnotateUtil = new SequenceAnnotateUtil(request, objectId);
    if (sequenceAnnotateUtil.getBioSequence()!=null) {
        for (String identifier : sequenceAnnotateUtil.getGeneFamilyIdentifiers()) {
            // only show for LIS gene families
            if (identifier.startsWith("legfed")) {
%>
    <form class="small-button" action="${WEB_PROPERTIES['annotate.url']}" method="post" target="_blank">
        <input type="hidden" name="fasta" value="<%=sequenceAnnotateUtil.getFasta()%>" />
        <input type="hidden" name="type" value="<%=sequenceAnnotateUtil.getSequenceType()%>" />
        <input type="hidden" name="geneFamily" value="<%=identifier%>" />
        <button type="submit">ANNOTATE</button>
    </form>
<%
            }
        }
    }
} catch (Exception ex) {
    // do nothing on keyword search result
}
%>
