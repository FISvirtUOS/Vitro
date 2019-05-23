<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Derzeit werden mit Blick auf die landesseitigen Anforderungen zur Transparenz in der Forschung zunächst <b>nur Publikationen abgebildet, die als Forschungsergebnisse aus zum Stichtag 1.12.2015 laufenden und bis 31.12.2017 abgeschlossenen drittmittelfinanzierten Projekten hervorgegangen sind</b>. Im Zuge der Integrierung der am Stichtag 1.12.2018 laufenden drittmittelfinanzierten Projekten werden ggf. vorhandene Publikationen mit aufgenommen.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>