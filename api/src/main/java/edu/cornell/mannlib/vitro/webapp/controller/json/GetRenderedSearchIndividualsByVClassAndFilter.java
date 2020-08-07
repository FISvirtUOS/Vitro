/* $This file is distributed under the terms of the license in LICENSE$ */

package edu.cornell.mannlib.vitro.webapp.controller.json;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import edu.cornell.mannlib.vitro.webapp.web.templatemodels.individual.IndividualTemplateModelBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.vitro.webapp.beans.Individual;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.dao.IndividualDao;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewService;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewService.ShortViewContext;
import edu.cornell.mannlib.vitro.webapp.services.shortview.ShortViewServiceSetup;

// new uos filter stuff
import org.apache.jena.query.Dataset;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.QuerySolutionMap;
import org.apache.jena.query.ResultSet;
import org.apache.jena.query.Syntax;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.tdb.TDBFactory;
import org.apache.jena.ontology.OntModel;
import edu.cornell.mannlib.vitro.webapp.controller.individuallist.IndividualListResults;
import edu.cornell.mannlib.vitro.webapp.controller.individuallist.IndividualListResultsUtils;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.IndividualListController;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.IndividualListController.PageRecord;
import edu.cornell.mannlib.vitro.webapp.utils.searchengine.SearchQueryUtils;

import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import javax.servlet.http.HttpServletResponse;



import java.util.Collections;


import org.apache.jena.rdf.model.RDFNode;
import java.util.ArrayList;
import java.util.Arrays;

import org.apache.jena.rdf.model.Literal;

/**
 * Does a search for individuals, and uses the short view to render each of
 * the results.
 */
public class GetRenderedSearchIndividualsByVClassAndFilter extends GetRenderedSearchIndividualsByVClass {
	private static final Log log = LogFactory
			.getLog(GetRenderedSearchIndividualsByVClassAndFilter.class);

	private final String count = "PREFIX kdsf: <http://kerndatensatz-forschung.de/owl/Basis#> SELECT (COUNT(?s) AS ?count) WHERE { ?s a kdsf:Drittmittelprojekt }";
	private final Query countQuery = QueryFactory.create(count, Syntax.syntaxSPARQL_11);

	private static final int INDIVIDUALS_PER_PAGE = 30;
    private static final int MAX_PAGES = 40;  // must be even


	protected GetRenderedSearchIndividualsByVClassAndFilter(VitroRequest vreq) {
		super(vreq);
	}

	/**
	 * Search for individuals by VClass or VClasses in the case of multiple parameters. The class URI(s) and the paging
	 * information are in the request parameters.
	 */
	@Override
	protected ObjectNode process() throws Exception {
		
		log.debug("Processing Query with Filters");
		String filterRT = vreq.getParameter("filterRT");
		String filterFB = vreq.getParameter("filterFB");
		String filterFD = vreq.getParameter("filterFD");
		String filterMG = vreq.getParameter("filterMG0");
		List<String> multiFilterMG = new ArrayList<String>();

		String alpha = SearchQueryUtils.getAlphaParameter(vreq);
        int page = SearchQueryUtils.getPageParameter(vreq);

		IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();

		//TODO Übergabe der Werte sicher machen, SQL-Injection!!!!

		if ((filterRT != null) || ( filterFB != null ) || ( filterFD != null )
			|| (filterMG != null ) || (alpha.equals("special"))) { // alpha workaround for sorting for special characters
			
			OntModel fullModel = vreq.getJenaOntModel();

			if (filterMG != null) {
				int counter = 1;
				multiFilterMG.add(filterMG);
				String tmp_filter  = vreq.getParameter("filterMG" + counter++);
				while (tmp_filter != null) {
					multiFilterMG.add(tmp_filter);

					vreq.getSession().setAttribute("filterMG" + counter, tmp_filter);
					
					tmp_filter  = vreq.getParameter("filterMG" + counter++);
				}
				vreq.getSession().setAttribute("filterMG", filterMG);
			}
			if (filterFB != null) {
				vreq.getSession().setAttribute("filterFB", filterFB);
			}
			if (filterFD != null) {
				vreq.getSession().setAttribute("filterFD", filterFD);
			}
			if (filterRT != null) {
				vreq.getSession().setAttribute("filterRT", filterRT);
			}	

			log.debug("Filter werden angewenden!");
			log.debug("FilterFB: " + filterFB + "\n FilterFD: " + filterFD + "\n FilterRT: " + filterRT + "\n FilterMG: " + filterMG + "\n Page: " + page + "\n Alpha: " + alpha );

			long estimate = -1;

			ParameterizedSparqlString pss = new ParameterizedSparqlString();
			ParameterizedSparqlString pss_count = new ParameterizedSparqlString();

			String count_query_string = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> "
			+ "PREFIX vivo: <http://vivoweb.org/ontology/core#> "
			+ "PREFIX kdsf: <http://kerndatensatz-forschung.de/owl/Basis#> "
			+ "SELECT (COUNT(DISTINCT ?Uri) AS ?count) ";


			String query_string = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> "
			+ "PREFIX vivo: <http://vivoweb.org/ontology/core#> "
			+ "PREFIX kdsf: <http://kerndatensatz-forschung.de/owl/Basis#> "
			+ "SELECT DISTINCT ?Uri ";
			
			
			String middle_query_string = "WHERE"
			+ "{ "
			+ "?Uri a kdsf:Drittmittelprojekt . "
			+ "?Uri rdfs:label ?label . ";

			if (filterFB != null) {
				middle_query_string += "?Uri kdsf:hatOrganisationseinheit ? . ";
			}

			if (filterFD != null) {
				middle_query_string += "?Uri kdsf:hatFach ? . ";
			}

			if (filterMG != null) {
				middle_query_string += " VALUES ?mittel {";
				for (String filter : multiFilterMG) {
					
					middle_query_string += " ? ";	
				}
				middle_query_string += "} ?Uri 	kdsf:hatMittelgeber  ?mittel . ";
			}

			if ( (filterRT != null ) && filterRT.equals("abgeschlossen")) {
				middle_query_string += "?Uri vivo:dateTimeInterval ?memberrole . "
							  + "?memberrole vivo:end ?enddate . "
							  + "?enddate vivo:dateTime ?end "
				  			  + "FILTER(?end < NOW())";
			} else if ( (filterRT != null ) && filterRT.equals("laufend")) {
				middle_query_string += "OPTIONAL{ "
							 + "?Uri vivo:dateTimeInterval ?memberrole . "
							 + "?memberrole vivo:end ?enddate . "
							 + "?enddate vivo:dateTime ?end "
							 + "} "
							 + "  FILTER( NOT EXISTS{SELECT ?dateend {?Uri vivo:dateTimeInterval ?memberrole . "
							 + "?memberrole vivo:end ?enddate . "
							 + "?enddate vivo:dateTime ?dateend}} || ?end > NOW()) ";
			} 

			String alpha_regex = "";
			if (alpha != null && (!alpha.equals("all"))) {
				if (alpha.equals("special")){
					alpha_regex = "FILTER REGEX (?label, '^[^A-Za-z]') .";
				} else {
					alpha_regex = "FILTER REGEX (?label, '^(" + alpha + "|" + alpha.toUpperCase() + ")') .";
				}
			}

			middle_query_string += alpha_regex 
								+ " } "
								+ "ORDER BY ASC(?label) ";
			

			count_query_string += middle_query_string;
			query_string += middle_query_string;

			int offset = (page -1) * INDIVIDUALS_PER_PAGE;
			query_string += " LIMIT " + INDIVIDUALS_PER_PAGE 
						 + " OFFSET " + offset;


			

			pss.setCommandText(query_string);
			pss_count.setCommandText(count_query_string);

			// neue query bauen
			int count = 0;
			if (filterFB != null) {
				pss_count.setIri(count, filterFB);
				pss.setIri(count++, filterFB);
			}
			if (filterFD != null) {
				pss_count.setIri(count, filterFD);
				pss.setIri(count++, filterFD);
			}
			if (filterMG != null) {
				for (String filter : multiFilterMG) {
					pss_count.setIri(count, filter);
					pss.setIri(count++, filter);
			}}
			

			try (QueryExecution qexec = QueryExecutionFactory.create(pss_count.toString(), fullModel)) {
				ResultSet results = qexec.execSelect();

				if (results.hasNext()) {
					QuerySolution soln = results.nextSolution() ;
					Literal literal = soln.getLiteral("count");
					estimate = literal.getLong();

					log.debug("Count aus eigener Abfrage:" + estimate);
				} else {
					log.debug("Bei der Abfrage ist nichts rausgekommen");
				}
			}


			log.debug("Folgende Query wird ausgeführt: " + pss.asQuery());
			

			try (QueryExecution qexec = QueryExecutionFactory.create(pss.toString(), fullModel)) {
				ResultSet results = qexec.execSelect();

				log.debug("Query wurde ausgeführt");
				RDFNode node;
				List<Individual> entities = new ArrayList<>();

				if (results.hasNext()) {
					while (results.hasNext()) {
						QuerySolution soln = results.next();

						if (soln != null) {
							node = soln.get("Uri");
							
							if (node != null) {
								
								Individual individual = iDao.getIndividualByURI(node.toString());
								if (individual == null) {
									log.debug("No individual for search document with uri = " + node.toString());
								} else {
									entities.add(individual);
									log.debug("Adding individual " + node.toString() + " to individual list");
								}
							}
							//}
						}
					}

					log.debug("Abfrage ergab Anzahl-Treffer: " + entities.size());vreq.getSession().setAttribute("test","hat geklappt");


					// Aus IndividualListController.java geklaut
					ObjectNode rObj;
					//addShortViewRenderings(rObj);
					
					IndividualListResults vcResults;
        			if ( estimate > INDIVIDUALS_PER_PAGE ){
						vcResults = new IndividualListResults(estimate, entities, alpha, true, 
									IndividualListController.makePagesList(estimate, INDIVIDUALS_PER_PAGE, page, vreq));
        			}else{
        				vcResults = new IndividualListResults(estimate, entities, alpha, false, Collections.<PageRecord>emptyList());
					}
					
					rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(vcResults, vreq, true);
					addShortViewRenderings(rObj);
					return rObj;

				} else {
					log.debug("Bei der Abfrage ist nichts rausgekommen, lade normale Klassenliste...");

					// return empty List with all required informations
					ObjectNode rObj;
					IndividualListResults vcResults = new IndividualListResults(0L, Collections.<Individual> emptyList(), alpha, false, 
					Collections .<PageRecord> emptyList());
					rObj = IndividualListResultsUtils.wrapIndividualListResultsInJson(vcResults, vreq, true);
					return rObj;
				}
			}
			
			
		} else {
			// ToDos entweder ohne Filter ausgeben oder leere Liste
			//return IndividualListResults.EMPTY;
			log.debug("Doch keine Filter gesetzt, lade normale Klassenliste...");
			return super.process();
		}
	}


	public void getFilter(HttpServletResponse resp) {

		log.debug("Mal gucken ob Filter gesetzt wurden");
		vreq.getSession().setAttribute("test","hat geklappt");
		ObjectNode rObj = JsonNodeFactory.instance.objectNode();

		String check = (String) vreq.getSession().getAttribute("filterFB");

		if(check != null) {
			log.debug("FilterFB aus Session geholt auf: " + check);
			rObj.put("filterFB", check);
		}

		check = (String) vreq.getSession().getAttribute("filterFD");

		if(check != null) {
			log.debug("FilterFD aus Session geholt auf: " + check);
			rObj.put("filterFD", check);
		}

		check = (String) vreq.getSession().getAttribute("filterRT");
		if(check != null) {
			log.debug("filterRT aus Session geholt auf: " + check);
			rObj.put("filterRT", check);
		}

		check = (String) vreq.getSession().getAttribute("filterMG");
		if(check != null) {
			log.debug("filterMG aus Session geholt auf: " + check);
			rObj.put("filterMG", check);
		}
		
		//return rObj;
		try {
			resp.setContentType("text/plain");  // Set content type of the response so that jQuery knows what it can expect.
			resp.setCharacterEncoding("UTF-8"); // You want world domination, huh?
			resp.getWriter().write(rObj.toString()); 
		} catch(Exception ex) {
			log.error("Error in get Filter Stuff", ex);
		}

		

	}

	/**
	 * Look through the return object. For each individual, render the short
	 * view and insert the resulting HTML into the object.
	 */
	private void addShortViewRenderings(ObjectNode rObj) {
		ArrayNode individuals = (ArrayNode) rObj.get("individuals");
		String vclassName = rObj.get("vclass").get("name").asText();
		for (int i = 0; i < individuals.size(); i++) {
			ObjectNode individual = (ObjectNode) individuals.get(i);
			individual.put("shortViewHtml",
					renderShortView(individual.get("URI").asText(), vclassName));
		}
	}

	private String renderShortView(String individualUri, String vclassName) {
		IndividualDao iDao = vreq.getWebappDaoFactory().getIndividualDao();
		Individual individual = iDao.getIndividualByURI(individualUri);

		Map<String, Object> modelMap = new HashMap<String, Object>();
		modelMap.put("individual",
				IndividualTemplateModelBuilder.build(individual, vreq));
		modelMap.put("vclass", vclassName);

		ShortViewService svs = ShortViewServiceSetup.getService(ctx);
		return svs.renderShortView(individual, ShortViewContext.BROWSE,
				modelMap, vreq);
	}
}
