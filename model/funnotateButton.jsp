<%@ page import="org.biojava.nbio.core.sequence.io.FastaWriterHelper" %>
<%@ page import="org.ncgr.intermine.web.logic.SequenceBlastUtil" %>
<%
// Display the ANNOTATE button to send the sequence to Funnotate
try {
    Integer objectId = Integer.parseInt(request.getParameter("id"));
    String sequenceType = request.getParameter("sequenceType");
    String geneFamily = request.getParameter("geneFamily");
    // create the FASTA using SequenceBlastUtil
    SequenceBlastUtil sequenceBlastUtil = new SequenceBlastUtil(request, objectId);
    if (sequenceBlastUtil.getBioSequence()!=null) {
        String fasta = ">"+sequenceBlastUtil.getIdentifier()+"\n"+sequenceBlastUtil.getBioSequence().toString();
  %>
<form action="${WEB_PROPERTIES['funnotate.url']}" method="post" style="display:inline;border:0;margin:0;padding:0;" target="_blank">
  <input type="hidden" name="fasta" value="<%=fasta%>" />
  <input type="hidden" name="type" value="<%=sequenceType%>" />
  <input type="hidden" name="geneFamily" value="<%=geneFamily%>" />
  <button type="submit" style="border:0;margin:0;padding:0;"><img class="fasta" src="model/images/annotate.png" title="ANNOTATE"/></button>
</form>
<%
    }
} catch (Exception e) {
  // do nothing
}
%>
