/* $This file is distributed under the terms of the license in LICENSE$ */

package edu.cornell.mannlib.vitro.webapp.controller.freemarker; 

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.vitro.webapp.beans.ApplicationBean;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.ResponseValues;
import edu.cornell.mannlib.vitro.webapp.controller.freemarker.responsevalues.TemplateResponseValues;

import javax.servlet.annotation.WebServlet;

@WebServlet(name = "ImprintController", urlPatterns = {"/imprint"} )
public class ImprintController extends FreemarkerHttpServlet {
	
    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(ImprintController.class);
    private static final String TEMPLATE_DEFAULT = "imprint.ftl";
    
    @Override
    protected ResponseValues processRequest(VitroRequest vreq) {
        ApplicationBean application = vreq.getAppBean();
        
        Map<String, Object> body = new HashMap<String, Object>();
        
        return new TemplateResponseValues(TEMPLATE_DEFAULT, body);
    }

    @Override
    protected String getTitle(String siteName, VitroRequest vreq) {
    	return "Imprint " + siteName;
    }

}
