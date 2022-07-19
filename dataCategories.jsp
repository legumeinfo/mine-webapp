<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<%@ page import="java.util.List,java.util.ArrayList,java.util.Map,java.util.LinkedHashMap" %>
<%@ page import="org.intermine.api.InterMineAPI" %>
<%@ page import="org.intermine.api.results.ExportResultsIterator,org.intermine.api.results.ResultElement" %>
<%@ page import="org.intermine.api.profile.Profile,org.intermine.api.query.PathQueryExecutor" %>
<%@ page import="org.intermine.objectstore.ObjectStore,org.intermine.objectstore.ObjectStoreException" %>
<%@ page import="org.intermine.metadata.Model" %>
<%@ page import="org.intermine.pathquery.Constraints,org.intermine.pathquery.OrderDirection,org.intermine.pathquery.PathQuery" %>
<%@ page import="org.intermine.web.logic.session.SessionMethods" %>
<!-- dataCategories -->
<c:set var="note1" value="This is note1, e.g. Only genes that have been mapped to the genome have been loaded."/>
<html:xhtml/>
<%
InterMineAPI im = SessionMethods.getInterMineAPI(session);
ObjectStore os = im.getObjectStore();
Model model = im.getModel();
Profile profile = SessionMethods.getProfile(session);
PathQueryExecutor executor = im.getPathQueryExecutor(profile);

// load the DataSources into an id-name map
// store the id of the LIS Datastore for future use
Map<Integer,String> sourceIdsNames = new LinkedHashMap<>();
int lisDatastoreId = 0;
PathQuery sourcesQuery = new PathQuery(model);
sourcesQuery.addView("DataSource.id");   // 1
sourcesQuery.addView("DataSource.name"); // 0
sourcesQuery.addOrderBy("DataSource.name", OrderDirection.ASC);
sourcesQuery.addConstraint(Constraints.isNotNull("DataSource.dataSets"));
ExportResultsIterator sourcesResult = executor.execute(sourcesQuery);
while (sourcesResult.hasNext()) {
    List<ResultElement> sourceRow = sourcesResult.next();
    Integer sourceId = (Integer) sourceRow.get(0).getField();   // 0 DataSource.id
    String sourceName = (String) sourceRow.get(1).getField();   // 1 DataSource.name
    sourceIdsNames.put(sourceId, sourceName);
    if (sourceName.equals("LIS Datastore")) lisDatastoreId = sourceId;
}

// load the DataSets into lists per DataSource along with their synopses and URLs
Map<Integer,List<String>> sourcesSetNames = new LinkedHashMap<>(); // keyed by DataSource.name
Map<String,String> setSynopses = new LinkedHashMap<>();            // keyed by DataSet.name
Map<String,String> setUrls = new LinkedHashMap<>();                // keyed by DataSet.name
Map<String,String> setDescriptions = new LinkedHashMap<>();        // keyed by DataSet.name
for (Integer sourceId : sourceIdsNames.keySet()) {
    List<String> setNames = new ArrayList<>();
    PathQuery setsQuery = new PathQuery(model);
    setsQuery.addView("DataSet.name");        // 0
    setsQuery.addView("DataSet.synopsis");    // 1
    setsQuery.addView("DataSet.url");         // 2
    setsQuery.addView("DataSet.description"); // 3
    setsQuery.addConstraint(Constraints.eq("DataSet.dataSource.id", String.valueOf(sourceId)));
    setsQuery.addOrderBy("DataSet.name", OrderDirection.ASC);
    ExportResultsIterator setsResult = executor.execute(setsQuery);
    while (setsResult.hasNext()) {
	// grab the fields
	List<ResultElement> setRow = setsResult.next();
	String name = (String) setRow.get(0).getField();          // 0 DataSet.name
	String synopsis = (String) setRow.get(1).getField();      // 1 DataSet.synopsis
	String url = (String) setRow.get(2).getField();           // 2 DataSet.url
        String description = (String) setRow.get(3).getField();   // 3 DataSet.description
	setNames.add(name);
	setSynopses.put(name, synopsis);
	setUrls.put(name, url);
        setDescriptions.put(name, description);
    }
    sourcesSetNames.put(sourceId, setNames);
}

// for the case of LIS sources group into collection categories
List<String> aboutSets = new ArrayList<>();
List<String> annotationSets = new ArrayList<>();
List<String> expressionSets = new ArrayList<>();
List<String> geneticSets = new ArrayList<>();
List<String> genomeSets = new ArrayList<>();
List<String> mapSets = new ArrayList<>();
List<String> markerSets = new ArrayList<>();
List<String> syntenySets = new ArrayList<>();
List<String> otherSets = new ArrayList<>();
for (String name : sourcesSetNames.get(lisDatastoreId)) {
    String url = setUrls.get(name);
    if (url!=null) {
        if (url.contains("about_this_collection")) {
            aboutSets.add(name);
        } else if (url.contains("/annotations/")) {
            annotationSets.add(name);
        } else if (url.contains("/expression/")) {
            expressionSets.add(name);
        } else if (url.contains("/genetic/")) {
            geneticSets.add(name);
        } else if (url.contains("/genomes/")) {
            genomeSets.add(name);
        } else if (url.contains("/maps/")) {
            mapSets.add(name);
        } else if (url.contains("/markers/")) {
            markerSets.add(name);
        } else if (url.contains("/synteny/")) {
            syntenySets.add(name);
        } else {
            otherSets.add(name);
        }
    } else {
        otherSets.add(name);
    }
}
%>
<div id="pagecontentcontainer" align="center">
    <div id="pagecontent" class="pagecontent-datacategories">
        <div class="datasource">LIS Datastore: species descriptions</div>
        <div class="dataset-row">
            <% for (String name : aboutSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setDescriptions.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: genome assemblies</div>
        <div class="dataset-row">
            <% for (String name : genomeSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: genome annotation</div>
        <div class="dataset-row">
            <% for (String name : annotationSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: gene expression</div>
        <div class="dataset-row">
            <% for (String name : expressionSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: genetic studies</div>
        <div class="dataset-row">
            <% for (String name : geneticSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: genetic maps</div>
        <div class="dataset-row">
            <% for (String name : mapSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: genetic markers</div>
        <div class="dataset-row">
            <% for (String name : markerSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: synteny</div>
        <div class="dataset-row">
            <% for (String name : syntenySets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <div class="datasource">LIS Datastore: other</div>
        <div class="dataset-row">
            <% for (String name : otherSets) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
        <%
        // non-LIS data sources
        for (Integer sourceId : sourceIdsNames.keySet()) {
            if (sourceId==lisDatastoreId) continue;
	    String sourceName = sourceIdsNames.get(sourceId);
	    List<String> setNames = sourcesSetNames.get(sourceId);
        %>
        <div class="datasource"><%=sourceName%></div>
        <div class="dataset-row">
            <% for (String name : setNames) { %>
                <div class="dataset-name"><%=name%></div>
                <div class="dataset-synopsis"><%=setSynopses.get(name)%></div>
                <div class="dataset-link">
                    <% if (setUrls.get(name)!=null) { %>
                        <a target="_blank" href="<%=setUrls.get(name)%>">LINK</a>
                    <% } %>
                </div>
            <% } %>
        </div>
  <%
  }
  %>
    </div>
</div>
<!-- /dataCategories -->
