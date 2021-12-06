<%@ page import="org.biojava.nbio.core.sequence.io.FastaWriterHelper" %>
<%@ page import="org.ncgr.intermine.web.logic.SequenceAnnotateUtil" %>
<%
// Display the ANNOTATE button to send the sequence to the annotate URL
try {
    Integer objectId = Integer.parseInt(request.getParameter("id"));
    // create the FASTA using SequenceAnnotateUtil
    SequenceAnnotateUtil sequenceAnnotateUtil = new SequenceAnnotateUtil(request, objectId);
    if (sequenceAnnotateUtil.getBioSequence()!=null) {
  %>
<form action="${WEB_PROPERTIES['annotate.url']}" method="post" style="display:inline;border:0;margin:0;padding:0;" target="_blank">
  <input type="hidden" name="fasta" value="<%=sequenceAnnotateUtil.getFasta()%>" />
  <input type="hidden" name="type" value="<%=sequenceAnnotateUtil.getSequenceType()%>" />
  <input type="hidden" name="geneFamily" value="<%=sequenceAnnotateUtil.getGeneFamilyIdentifier()%>" />
  <button type="submit" style="border:0;margin:0;padding:0;"><img class="fasta" src="model/images/annotate.png" title="ANNOTATE"/></button>
</form>
<%
    }
} catch (Exception e) {
  // do nothing
}
%>
