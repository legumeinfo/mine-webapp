<%@ page import="org.biojava.nbio.core.sequence.io.FastaWriterHelper" %>
<%@ page import="org.ncgr.intermine.web.logic.SequenceBlastUtil" %>
<%
// Display the BLAST button to send the sequence to the SequenceServer
try {
    Integer objectId = Integer.parseInt(request.getParameter("id"));
    SequenceBlastUtil sequenceBlastUtil = new SequenceBlastUtil(request, objectId);
    if (sequenceBlastUtil.getBioSequence()!=null) {
        String fasta = ">"+sequenceBlastUtil.getIdentifier()+"\n"+sequenceBlastUtil.getBioSequence().toString();
  %>
<form action="${WEB_PROPERTIES['sequenceserver.url']}" method="post" style="display:inline;border:0;margin:0;padding:0;" target="_blank">
  <input type="hidden" name="input_sequence" value="<%=fasta%>" />
  <button type="submit" style="border:0;margin:0;padding:0;"><img class="fasta" src="model/images/blast.png" title="BLAST"/></button>
</form>
<%
    }
} catch (Exception e) {
  // do nothing
}
%>
