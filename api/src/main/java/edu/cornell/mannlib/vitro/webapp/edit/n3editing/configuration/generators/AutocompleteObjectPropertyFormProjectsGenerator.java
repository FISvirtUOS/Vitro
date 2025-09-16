/* $This file is distributed under the terms of the license in LICENSE$ */

package edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.generators;

import javax.servlet.http.HttpSession;

import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.EditConfigurationVTwo;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import edu.cornell.mannlib.vitro.webapp.beans.VClass;
import edu.cornell.mannlib.vitro.webapp.edit.n3editing.VTwo.EditConfigurationUtils;

import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchEngine;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchEngineException;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchQuery;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResponse;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResultDocumentList;
import edu.cornell.mannlib.vitro.webapp.search.VitroSearchTermNames;

import edu.cornell.mannlib.vitro.webapp.application.ApplicationUtils;

import edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary;


/**
 * Auto complete object property form generator folded into DefualtObjectPropertyFormGenerator.java
 *
 */
public class AutocompleteObjectPropertyFormProjectsGenerator extends DefaultObjectPropertyFormGenerator {

	private Log log = LogFactory.getLog(AutocompleteObjectPropertyFormProjectsGenerator.class);

	String template = "autoCompleteObjectPropertyFormProjects.ftl";

	String objectPropertyTemplate = "defaultPropertyForm.ftl";
	String acObjectPropertyTemplate = "autoCompleteObjectPropertyFormProjects.ftl";

	@Override
	public EditConfigurationVTwo getEditConfiguration(VitroRequest vreq,
			HttpSession session) throws Exception {
		//force auto complete
		doAutoComplete = true;

		

		log.info("Wird aber aufgerufen");

		return super.getEditConfiguration(vreq, session);
	}

	protected String getTemplate() {
		return "autoCompleteObjectPropertyFormProjects.ftl";
	}

	public void addFormSpecificDataForAC(EditConfigurationVTwo editConfiguration, VitroRequest vreq, HttpSession session) throws SearchEngineException {
		HashMap<String, Object> formSpecificData = new HashMap<String, Object>();
		//Get the edit mode
		formSpecificData.put("editMode", getEditMode(vreq).toString().toLowerCase());

		//We also need the type of the object itself
		List<VClass> types = getRangeTypes(vreq);
        //if types array contains only owl:Thing, the search will not return any results
        //In this case, set an empty array
        if(types.size() == 1 && types.get(0).getURI().equals(VitroVocabulary.OWL_THING) ){
        	types = new ArrayList<VClass>();
        }

        StringBuilder typesBuff = new StringBuilder();
        for (VClass type : types) {
            if (type.getURI() != null) {
                typesBuff.append(type.getURI()).append(",");
            }
        }

		formSpecificData.put("objectTypes", typesBuff.toString());
		log.debug("autocomplete object types : "  + formSpecificData.get("objectTypes"));

		//Get label for individual if it exists
		if(EditConfigurationUtils.getObjectIndividual(vreq) != null) {
			String objectLabel = EditConfigurationUtils.getObjectIndividual(vreq).getName();
			formSpecificData.put("objectLabel", objectLabel);
		}

		//TODO: find out if there are any individuals in the classes of objectTypes
		formSpecificData.put("rangeIndividualsExist", rangeIndividualsExist(types) );

		formSpecificData.put("sparqlForAcFilter", getSparqlForAcFilter(vreq));
		if(customErrorMessages != null && !customErrorMessages.isEmpty()) {
			formSpecificData.put("customErrorMessages", customErrorMessages);
		}
		editConfiguration.setTemplate(acObjectPropertyTemplate);
		editConfiguration.setFormSpecificData(formSpecificData);
	}

	private Object rangeIndividualsExist(List<VClass> types) throws SearchEngineException {
		SearchEngine searchEngine = ApplicationUtils.instance().getSearchEngine();

    	boolean rangeIndividualsFound = false;
    	for( VClass type:types){
    		//search  for type count.
    		SearchQuery query = searchEngine.createQuery();
    		query.setQuery( VitroSearchTermNames.RDFTYPE + ":" + type.getURI());
    		query.setRows(0);

    		SearchResponse rsp = searchEngine.query(query);
    		SearchResultDocumentList docs = rsp.getResults();
    		if( docs.getNumFound() > 0 ){
    			rangeIndividualsFound = true;
    			break;
    		}
    	}

    	return  rangeIndividualsFound;
	}



}
