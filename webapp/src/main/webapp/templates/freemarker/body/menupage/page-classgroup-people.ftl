<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Derzeit sind zum 31.12.2017 an der Universität Osnabrück beschäftigte Professorinnen und Professoren mit jeweiligem Status im System abgebildet. Abgebildet sind zudem zum Stichtag beschäftigte wissenschaftliche Mitarbeiterinnen und Mitarbeiter, sofern diese an in den Jahren 2015 und 2016 abgeschlossenen drittmittelfinanzierten Projekten beteiligt waren. Im System abgebildet werden zudem jene Projektverantwortliche, die am 31.12.2017 nicht mehr an der Universität beschäftigt waren, aber für zum Stichtag 1.12.2015 laufende und bis 2017 abgeschlossene drittmittelfinanzierte Projekte verantwortlich bzw. an diesen Projekten beteiligt waren.
Im Laufe des akademischen Jahres 2019 werden diese Informationen sukzessive um wissenschaftliche Mitarbeiterinnen und Mitarbeiter bzw. an drittmittelfinanzierten Projekten Beteiligte ergänzt.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>