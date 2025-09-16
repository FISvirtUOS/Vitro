<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Gemeinsam mit der Universität Osnabrück lädt die Neue Osnabrücker Zeitung jedes Jahr zum Osnabrücker Wissensforum ein. Bürgerinnen und Bürger können vorab Fragen einsenden, die ihnen auf den Nägeln brennen. Die Herausforderung: Jede Wissenschaftlerin und jeder Wissenschaftler hat an dem Abend für seinen Vortrag nur vier Minuten Zeit. Wer überzieht, bekommt die Rote Karte. Mit dem Osnabrücker Wissensforum soll der Dialog zwischen Stadt und Universität gestärkt, der Bedeutung von Wissenschaft für die Zukunftsfähigkeit unserer Gesellschaft gerecht werden und den Blick auf den Wissenschaftsstandort Osnabrück lenken. Nicht zuletzt soll die Vielfalt und Faszination des wissenschaftlichen Arbeitens einer breiteren Öffentlichkeit präsentiert werden.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>