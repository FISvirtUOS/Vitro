<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Derzeit werden mit Blick auf die landesseitigen Anforderungen zur Transparenz in der Forschung zunächst nur Publikationen abgebildet, die als Forschungsergebnisse aus zum Stichtag 1.12.2015 laufenden und bis 31.12.2018 abgeschlossenen drittmittelfinanzierten Projekten hervorgegangen sind. Die Projektveröffentlichungen werden sukzessive nachgepflegt und sollen zukünftig mit Hilfe einer Schnittstelle zur Universitätsbibliothek automatisiert eingebunden werden.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>