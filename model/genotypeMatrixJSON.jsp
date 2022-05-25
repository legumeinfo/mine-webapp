<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.intermine.api.InterMineAPI,org.intermine.api.bag.BagManager,org.intermine.api.profile.Profile,org.intermine.api.profile.InterMineBag" %>
<%@ page import="org.intermine.api.query.PathQueryExecutor,org.intermine.api.results.ExportResultsIterator,org.intermine.api.results.ResultElement" %>
<%@ page import="org.intermine.web.logic.session.SessionMethods" %>
<%@ page import="org.intermine.pathquery.Constraints,org.intermine.pathquery.OrderDirection,org.intermine.pathquery.PathQuery,org.intermine.pathquery.OuterJoinStatus" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Map,java.util.LinkedHashMap,java.util.TreeSet,java.util.List,java.util.LinkedList,java.util.Iterator" %>
<%@ page import="java.text.DecimalFormat" %>
<%
// HTTP REQUEST VARS
String studyPrimaryIdentifier = request.getParameter("studyPrimaryIdentifier");
String chrName = request.getParameter("chrName");
int genotypingRecordLength = Integer.parseInt(request.getParameter("genotypingRecordLength"));
int genotypingRecordStart = Integer.parseInt(request.getParameter("genotypingRecordStart"));
int genotypingRecordAdvance = Integer.parseInt(request.getParameter("genotypingRecordAdvance"));
int orderColumn = Integer.parseInt(request.getParameter("orderColumn"));
String orderDir = request.getParameter("orderDir");
boolean isHeaderQuery = request.getParameter("isHeaderQuery")!=null;

// DataTables paging request parameters
int draw = 0;
int start = 0;
int length = 0;
if (request.getParameter("draw")!=null) draw = Integer.parseInt(request.getParameter("draw"));     // increases monotonically on each page draw
if (request.getParameter("start")!=null) start = Integer.parseInt(request.getParameter("start"));   // starting row, zero-based: 0, 25, 50, ...
if (request.getParameter("length")!=null) length = Integer.parseInt(request.getParameter("length")); // number of rows: 25, 50, etc. -1 means "all"

// String sampleSortName = request.getParameter("sampleSortName").trim();
// String sampleListName = request.getParameter("sampleListName").trim();
// String genotypingRecordListName = request.getParameter("genotypingRecordListName").trim();

// validation
if (studyPrimaryIdentifier==null) {
    out.println("<h1>studyPrimaryIdentifier missing in genotypeMatrixJSON call.</h1>");
    System.err.println("studyPrimaryIdentifier missing in genotypeMatrixJSON call.");
    return;
}

// initialize mine API, etc.
InterMineAPI im = SessionMethods.getInterMineAPI(session);
Profile user = SessionMethods.getProfile(session);
PathQueryExecutor executor = im.getPathQueryExecutor(user);
ExportResultsIterator iterator;

if (isHeaderQuery) {
    /***************************************
     * Return the table header with paging *
     ***************************************/
    // this object will become the list of column headers
    List<Object> headerList = new LinkedList<Object>();
    // query genotyping records with paging
    // ASSUME MARKER
    PathQuery genotypingHeaderQuery = new PathQuery(im.getModel());
    genotypingHeaderQuery.addViews("GenotypingRecord.markers.name",                           // 0
                                   "GenotypingRecord.markers.chromosome.name",                // 1
                                   "GenotypingRecord.markers.chromosomeLocation.start");      // 2
    genotypingHeaderQuery.addConstraint(Constraints.eq("GenotypingRecord.study.primaryIdentifier", studyPrimaryIdentifier));
    genotypingHeaderQuery.addConstraint(Constraints.eq("GenotypingRecord.markers.chromosome.name", chrName));
    genotypingHeaderQuery.addOrderBy("GenotypingRecord.markers.chromosomeLocation.start", OrderDirection.ASC);
    // get the record count for this chromosome
    int genotypingRecordCount = executor.count(genotypingHeaderQuery);
    // run the genotyping record query with paging
    if (genotypingRecordLength>0) {
        iterator = executor.execute(genotypingHeaderQuery, genotypingRecordStart, genotypingRecordLength);
    } else {
        iterator = executor.execute(genotypingHeaderQuery);
    }
    while (iterator.hasNext()) {
        List<ResultElement> results = iterator.next();
        Integer markerId = (Integer) results.get(0).getId();
        String marker = (String) results.get(0).getField();
        String chromosome = (String) results.get(1).getField();
        Integer location = (Integer) results.get(2).getField();
        String heading = "<a class='genotypingHeader' href='report.do?id="+markerId+"'>";
        if (marker!=null) heading += marker+"<br/>";
        heading += chromosome+"<br/>"+location+"</a>";
        headerList.add(heading);
    }
    // buffer if less than genotypingRecordLength records
    int bufferNum = genotypingRecordLength - headerList.size();
    if (bufferNum>0) {
        for (int i=0; i<bufferNum; i++) {
            headerList.add("");
        }
    }
    // form the JSON response
    Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();
    jsonMap.put("genotypingRecordCount", new Integer(genotypingRecordCount));
    jsonMap.put("header", headerList.toArray());
    // write the JSON to the response
    try {
        JSONObject json = new JSONObject(jsonMap);
        response.setContentType("application/json");
        json.write(response.getWriter());
    } catch (Exception ex) {
        JSONObject json = new JSONObject(jsonMap);
        jsonMap.put("error", ex.toString());
        response.setContentType("application/json");
        json.write(response.getWriter());
        throw new RuntimeException(ex);
    }
} else {
    /************************************************
     * Return the samples and genotypes with paging *
     ************************************************/
    PathQuery sampleQuery = new PathQuery(im.getModel());
    sampleQuery.addView("GenotypingSample.primaryIdentifier"); // 0
    sampleQuery.addConstraint(Constraints.eq("GenotypingSample.study.primaryIdentifier", studyPrimaryIdentifier));
    sampleQuery.addOrderBy("GenotypingSample.primaryIdentifier", OrderDirection.ASC);
    // get total samples for datatables
    int recordsTotal = executor.count(sampleQuery);
    // get paged samples
    if (length>0) {
        iterator = executor.execute(sampleQuery, start, length);
    } else {
        iterator = executor.execute(sampleQuery);
    }
    Map<Integer,String> samples = new LinkedHashMap<>();
    Map<String,Integer> sampleIds = new LinkedHashMap<>();
    while (iterator.hasNext()) {
        List<ResultElement> results = iterator.next();
        Integer id = results.get(0).getId();
        String sample = (String) results.get(0).getField();
        samples.put(id, sample);
        sampleIds.put(sample, id);
    }
    
    // query genotyping records with paging
    // ASSUME MARKERS
    List<String> genotypingRecordIdStrings = new LinkedList<>();             // convenience for Constraints.oneOfValues
    Map<Integer,String> genotypingRecordMarkerNames = new LinkedHashMap<>(); // keyed by GenotypingRecord id
    Map<Integer,String> genotypingRecordChromosomes = new LinkedHashMap<>(); // keyed by GenotypingRecord id
    Map<Integer,Integer> genotypingRecordLocations = new LinkedHashMap<>();  // keyed by GenotypingRecord id
    PathQuery genotypingRecordQuery = new PathQuery(im.getModel());
    genotypingRecordQuery.addViews("GenotypingRecord.markerName",                        // 0
                                   "GenotypingRecord.markers.chromosome.name",           // 1
                                   "GenotypingRecord.markers.chromosomeLocation.start"); // 2
    genotypingRecordQuery.addConstraint(Constraints.eq("GenotypingRecord.study.primaryIdentifier", studyPrimaryIdentifier));
    genotypingRecordQuery.addConstraint(Constraints.eq("GenotypingRecord.markers.chromosome.name", chrName));
    genotypingRecordQuery.addOrderBy("GenotypingRecord.markers.chromosomeLocation.start", OrderDirection.ASC);
    if (genotypingRecordLength>0) {
        iterator = executor.execute(genotypingRecordQuery, genotypingRecordStart, genotypingRecordLength);
    } else {
        iterator = executor.execute(genotypingRecordQuery);
    }
    while (iterator.hasNext()) {
        List<ResultElement> results = iterator.next();
        Integer id = results.get(0).getId();
        String markerName = (String) results.get(0).getField();
        String chromosome = (String) results.get(1).getField();
        Integer location = (Integer) results.get(2).getField();
        genotypingRecordIdStrings.add(String.valueOf(id));
        genotypingRecordMarkerNames.put(id, markerName);
        genotypingRecordChromosomes.put(id, chromosome);
        genotypingRecordLocations.put(id, location);
    }
    // query genotype values for each sample and GenotypingRecord
    // NOTE: genotypingSampleRecord is a simple object!
    // ASSUMES MARKER
    Map<Integer,String[]> genotypesMap = new LinkedHashMap<>(); // keyed by sampleId
    if (genotypingRecordIdStrings.size()>0) {
        for (Integer sampleId : samples.keySet()) {
            String sample = samples.get(sampleId);
            PathQuery genotypeQuery = new PathQuery(im.getModel());
            genotypeQuery.addViews("Genotype.value",                                        // 0
                                   "Genotype.record.markers.chromosomeLocation.start");     // 1
            genotypeQuery.addConstraint(Constraints.eq("Genotype.sample.id", String.valueOf(sampleId)));
            genotypeQuery.addConstraint(Constraints.oneOfValues("Genotype.record.id", genotypingRecordIdStrings));
            genotypeQuery.addOrderBy("Genotype.record.markers.chromosomeLocation.start", OrderDirection.ASC);
            iterator = executor.execute(genotypeQuery);
            String[] genotypes = new String[genotypingRecordIdStrings.size()];
            int i = 0;
            while (iterator.hasNext()) {
                List<ResultElement> results = iterator.next();
                genotypes[i++] = (String) results.get(0).getField();
            }
            genotypesMap.put(sampleId, genotypes);
        }
    }
    // sort based on orderColumn and orderDir
    // [0,asc] is what we already have
    LinkedHashMap<String,Integer> sortedSamples = new LinkedHashMap<>();
    boolean descending = orderDir.equals("desc");
    if (orderColumn==0) {
        // simple sample sorting in orderDir direction
        TreeSet<String> sampleSet = new TreeSet<>(sampleIds.keySet());
        if (descending) {
            for (String sample : sampleSet.descendingSet()) {
                sortedSamples.put(sample, sampleIds.get(sample));
            }
        } else {
            for (String sample : sampleSet) {
                sortedSamples.put(sample, sampleIds.get(sample));
            }
        }    
    } else if (genotypesMap.size()>0) {
        // sort on the chosen column of genotypes + sample
        TreeSet<String> genotypeSampleSet = new TreeSet<>();
        int idx = orderColumn - 1;
        for (String sample : sampleIds.keySet()) {
            String[] genotypes = genotypesMap.get(sampleIds.get(sample));
            genotypeSampleSet.add(genotypes[idx]+"+"+sample);
        }
        if (descending) {
            for (String genotypeSample : genotypeSampleSet.descendingSet()) {
                String[] parts = genotypeSample.split("\\+");
                String sample = parts[1];
                sortedSamples.put(sample, sampleIds.get(sample));
            }
        } else {
            for (String genotypeSample : genotypeSampleSet) {
                String[] parts = genotypeSample.split("\\+");
                String sample = parts[1];
                sortedSamples.put(sample, sampleIds.get(sample));
            }
        }
    }
    ////////////////////
    // build the JSON //
    ////////////////////
    // this object will become the table body data
    List<Object> dataList = new LinkedList<Object>();

    // unwrap the genotypes into data rows with sample at left
    for (String sample : sortedSamples.keySet()) {
        int sampleId = sortedSamples.get(sample);
        List<Object> genotypesRow = new LinkedList<Object>();
        String[] genotypes = genotypesMap.get(sampleId);
        String heading = "<a href='report.do?id="+sampleId+"'>"+sample+"</a>";
        // leading sample column
        genotypesRow.add(heading);
        // genotypes in rest of columns
        int count = 0;
        for (String genotype : genotypes) {
            genotypesRow.add(genotype);
            count++;
        }
        // buffer empty cells, if present
        int bufferNum = genotypingRecordLength - count;
        if (bufferNum>0) {
            for (int i=0; i<bufferNum; i++) {
                genotypesRow.add(' ');
            }
        }
        dataList.add(genotypesRow.toArray());
    }
    // create the JSON response using the Map to JSON utility
    Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();
    jsonMap.put("draw", draw);
    jsonMap.put("recordsTotal", recordsTotal);
    jsonMap.put("recordsFiltered", recordsTotal);
    jsonMap.put("data", dataList.toArray());
    // write the JSON to the response
    try {
        JSONObject json = new JSONObject(jsonMap);
        response.setContentType("application/json");
        json.write(response.getWriter());
    } catch (Exception ex) {
        JSONObject json = new JSONObject(jsonMap);
        jsonMap.put("error", ex.toString());
        response.setContentType("application/json");
        json.write(response.getWriter());
        throw new RuntimeException(ex);
    }
}
%>
