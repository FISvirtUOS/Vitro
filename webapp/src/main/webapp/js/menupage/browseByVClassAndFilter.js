/* $This file is distributed under the terms of the license in LICENSE$ */

var browseByVClass = {
    // Initial page setup
    onLoad: function() {
        this.mergeFromTemplate();
        this.initObjects();
        this.bindEventListeners();
        this.defaultVClass();

        $(".js-select2").select2({
			closeOnSelect : false,
			placeholder : " Mittelgeber",
			allowHtml: true,
			allowClear: true,
			tags: true
        });

    },
    
    // Add variables from menupage template
    mergeFromTemplate: function() {
        $.extend(this, menupageData);
        $.extend(this, i18nStrings);
    },
    
    // Create references to frequently used elements for convenience
    initObjects: function() {
        this.vgraphVClasses = $('#vgraph-classes');
        this.vgraphVClassLinks = $('#vgraph-classes li a');
        this.browseVClasses = $('#browse-classes');
        this.browseVClassLinks = $('#browse-classes li a');
        this.alphaIndex = $('#alpha-browse-individuals');
        this.alphaIndexLinks = $('#alpha-browse-individuals li a');
        this.individualsInVClass = $('#individuals-in-class ul');
        this.individualsContainer = $('#individuals-in-class');
    },
    
    // Event listeners. Called on page load
    bindEventListeners: function() {
        // Listeners for vClass switching
        this.vgraphVClassLinks.click(function() {
            var uri = $(this).attr('data-uri');
            browseByVClass.getIndividuals(uri);
        });
        
        this.browseVClassLinks.click(function() {
            var uri = $(this).attr('data-uri');
            browseByVClass.getIndividuals(uri);
            return false;
        });
        
        // Listener for alpha switching
        this.alphaIndexLinks.click(function() {
            var uri = $('#browse-classes li a.selected').attr('data-uri');
            var alpha = $(this).attr('data-alpha');

            // check if some filters are set
            var filterRT = $('#savefilterRT').val();
            var filterFB = $('#savefilterFB').val();
            var filterFD = $('#savefilterFD').val();
            var filterMG = $('#savefilterMG').val();

            // if filters are set, get individuals with filters
            if ( (filterRT || filterFB || filterFD || filterMG) || alpha == "special" ) {
                browseByVClass.getIndividualsWithFilters( alpha, 1, false)
                return false
            } else { // else get all Drittmittel instances
                browseByVClass.getIndividuals(uri, alpha);
                return false;
            }
        });
        
        // save the selected vclass in location hash so we can reset the selection
        // if the user navigates with the back button
        this.browseVClasses.children('li').each( function() {
           $(this).find('a').click(function () {
                // the extra space is needed to prevent odd scrolling behavior -> i removed it internal ticket FisvirtUOS/VIVO#72
                location.hash = $(this).attr('data-uri');
           }); 
        });

        $("#resetFilterButton").click(function() {
            browseByVClass.defaultVClass();
            return false;
        });

        // Call the pagination listener
        this.paginationListener();

        // Call the filter Listener
        this.filterListener();
    },
    
    // Listener for page switching -- separate from the rest because it needs to be callable
    paginationListener: function() {
        $('.pagination li a').click(function() {
            var filterRT = $('#savefilterRT').val();
            var filterFB = $('#savefilterFB').val();
            var filterFD = $('#savefilterFD').val();
            var filterMG = $('#savefilterMG').val();

            var uri = $('#browse-classes li a.selected').attr('data-uri');
            var alpha = $('#alpha-browse-individuals li a.selected').attr('data-alpha');
            var page = $(this).attr('data-page');

            if (filterRT || filterFB || filterFD || filterMG) {
                browseByVClass.getIndividualsWithFilters( alpha, page, false)
                return false
            } else {
                browseByVClass.getIndividuals(uri, alpha, page);
                return false;
            }
        });
    },

    // Listener for page filtering
    filterListener: function() {
        $('#applyFilterButton').click(function() {
            var filter_set = false;

            //set filter in invisible field in Dom
            var filterRT = $('#filterRT').val();
            $("#savefilterRT").val(filterRT);
            if (filterRT != "") {
                filter_set = true;
            }

            var filterFB = $('#filterFB').val();
            $("#savefilterFB").val(filterFB);
            if (filterFB != "") {
                filter_set = true;
            }

            var filterFD = $('#filterFD').val();
            $("#savefilterFD").val(filterFD);
            if (filterFD != "") {
                filter_set = true;
            }

            // get the MG-filter
            var filterMG = "";
            var brands = $('#filterMG option:selected');
            var selected = [];
            $(brands).each(function(index, brand){
                filterMG += ([$(this).text()]) + " / ";
            });
            
            if (filterMG != ""){
                filter_set = true;
                $("#savefilterMG").val(brands);
                // var filterText = filterMG.slice(0, -3)
            } else {
                $("#savefilterMG").val("");
            }
            

            if (filter_set == true) {
                // do the magic Sparql Query stuff :P
                browseByVClass.getIndividualsWithFilters("all", 1, false);

                // activate/show reset filter button
                $("#resetFilterButton").prop('disabled', false);
                $("#resetFilterButton").show();
            } else {
                // activate/show reset filter button
                $("#resetFilterButton").prop('disabled', true);
                $("#resetFilterButton").hide();

                var uri = $('#browse-classes li a.selected').attr('data-uri');
                browseByVClass.getIndividuals(uri, "all", false);
            }
 
        });
    },
    

    // check for existing filters
    checkForFilter: function() {
        
        $.getJSON("/vivouos/dataservice?getFilterForRenderedSearchIndividualsByVClass=1", function(results) {
            var individualList = "";
            
            // Catch exceptions when empty individuals result set is returned
            // This is very likely to happen now since we don't have individual counts for each letter and always allow the result set to be filtered by any letter
            if ( results == null ) {
                //do nothing
            } else {
                if (results.filterFB != null) {
                    $("#saveFilterFB").val(results.filterFB);
                }
                if (results.filterFD != null) {
                    $("#saveFilterFD").val(results.filterFD);
                }
                if (results.filterRT != null) {
                    $("#saveFilterRT").val(results.filterRT);
                }
                if (results.filterMG != null) {
                    $("#saveFilterMG").val(results.filterMG);
                }
            }
        });
    },

    // Load individuals for default class as specified by menupage template
    defaultVClass: function() {
        if ( this.defaultBrowseVClassURI != "false" ) {
            if ( location.hash ) {
                // remove the trailing white space
                location.hash = location.hash.replace(/\s+/g, '');                
                this.getIndividuals(location.hash.substring(1,location.hash.length), "all", 1, false);
            }
            else {
                this.getIndividuals(this.defaultBrowseVClassUri, "all", 1, false);
            }
        }
    },
    
    // Where all the magic happens -- gonna fetch me some individuals
    getIndividuals: function(vclassUri, alpha, page, scroll) {
        // start the loading animation
        browseByVClass.ajaxStart();
        
        var url = this.dataServiceUrl + encodeURIComponent(vclassUri);

        if ( alpha && alpha != "all") {
            url += '&alpha=' + alpha;
        }
        if ( page ) {
            url += '&page=' + page;
        } else {
            page = 1;
        }
        if ( typeof scroll === "undefined" ) {
            scroll = true;
        }
        
        // Scroll to #menupage-intro page unless told otherwise
        if ( scroll != false ) {
            // only scroll back up if we're past the top of the #browse-by section
            var scrollPosition = browseByVClass.getPageScroll();
            var browseByOffset = $('#browse-by').offset();
            if ( scrollPosition[1] > browseByOffset.top) {
                $.scrollTo('#menupage-intro', 500);
            }
        }
        
        $.getJSON(url, function(results) {
            var individualList = "";
            
            // Catch exceptions when empty individuals result set is returned
            // This is very likely to happen now since we don't have individual counts for each letter and always allow the result set to be filtered by any letter
            if ( results.individuals.length == 0 ) {
                browseByVClass.emptyResultSet(results.vclass, alpha, false)
            } else {
                var vclassName = results.vclass.name;
                $.each(results.individuals, function(i, item) {
                    var individual = results.individuals[i];
                    individualList += individual.shortViewHtml;
                })
                
                // Remove existing content
                browseByVClass.wipeSlate();
                
                // And then add the new content
                browseByVClass.individualsInVClass.append(individualList);
                
                // Check to see if we're dealing with pagination
                if ( results.pages.length ) {
                    var pages = results.pages;
                    browseByVClass.pagination(pages, page);
                }

                if (results.totalCount) {
                    document.getElementById("class-counter").innerHTML = "(" + results.totalCount + ")";
                }
            }
            
            // Set selected class, alpha and page
            // Do this whether or not there are any results
            browseByVClass.selectedVClass(results.vclass.URI);
            browseByVClass.selectedAlpha(alpha);

            // remove loading screen
            browseByVClass.ajaxStop();
        });
    },

    getIndividualsWithFilters: function( alpha, page, scroll) {
        
        // start the loading animation
        browseByVClass.ajaxStart();

        var filterRT = $('#savefilterRT').val();
        var filterFB = $('#savefilterFB').val();
        var filterFD = $('#savefilterFD').val();

        var brands = $('#filterMG option:selected');
        var filterMG = [];
        $(brands).each(function(index, brand){
            filterMG.push([$(this).val()]);
        });

        var url = "/vivouos/dataservice?getRenderedSearchIndividualsByVClassAndFilter=1&vclassId=http%3A%2F%2Fkerndatensatz-forschung.de%2Fowl%2FBasis%23Drittmittelprojekt";

        var filter_set = false;

        if ( alpha && alpha != "all") {
            url += '&alpha=' + alpha;

            if (alpha == "special") filter_set = true; //workarount for alpha for sepcial characters
        }
        if ( page ) {
            url += '&page=' + page;
        }
        if ( filterRT ) {
            filter_set = true;
            url += '&filterRT=' + filterRT;
        }
        if ( filterFB ) {
            filter_set = true;
            url += '&filterFB=' + filterFB;
        }
        if ( filterFD ) {
            filter_set = true;
            url += '&filterFD=' + filterFD;
        }
        if ( filterMG.length != 0 ) {
            filter_set = true;

            filterMG.forEach(function(item, index, array) {
                url += '&filterMG' + index + '=' + item;
            });
        }

        // if there are active filters
        if (filter_set)
        {
            $.getJSON(url, function(results) {
                var individualList = "";
                
                // Catch exceptions when empty individuals result set is returned
                // This is very likely to happen now since we don't have individual counts for each letter and always allow the result set to be filtered by any letter
                if ( typeof results == 'undefined' || typeof results.individuals == 'undefined' || results.individuals.length == 0 ) {
                    browseByVClass.emptyResultSet(results.vclass, alpha, true)
                } else {
                    var vclassName = results.vclass.name;
                    $.each(results.individuals, function(i, item) {
                        var individual = results.individuals[i];
                        individualList += individual.shortViewHtml;
                    })
                    
                    // Remove existing content
                    browseByVClass.wipeSlate();
                    
                    // And then add the new content
                    browseByVClass.individualsInVClass.append(individualList);
                    
                    // Check to see if we're dealing with pagination
                    if ( results.pages.length ) {
                        var pages = results.pages;
                        browseByVClass.pagination(pages, page);
                    }
                }

                var total_count = results.totalCount;
                if (total_count) {
                    document.getElementById("class-counter").innerHTML = "(" + total_count + ")";
                }
                
                // Set selected class, alpha and page
                // Do this whether or not there are any results
                browseByVClass.selectedVClass(results.vclass.URI);
                browseByVClass.selectedAlpha(alpha);

                // stop the loading animation
                browseByVClass.ajaxStop();
            });
        } else { // if no active filters then load de default
            this.defaultVClass();

            //browseByVClass.ajaxStop();
        }
    },
    
    // getPageScroll() by quirksmode.org
    getPageScroll: function() {
        var xScroll, yScroll;
        if (self.pageYOffset) {
          yScroll = self.pageYOffset;
          xScroll = self.pageXOffset;
        } else if (document.documentElement && document.documentElement.scrollTop) {
          yScroll = document.documentElement.scrollTop;
          xScroll = document.documentElement.scrollLeft;
        } else if (document.body) {// all other Explorers
          yScroll = document.body.scrollTop;
          xScroll = document.body.scrollLeft;
        }
        return new Array(xScroll,yScroll)
    },
    
    // Print out the pagination nav if called
    pagination: function(pages, page) {
        var pagination = '<div class="pagination menupage">';
        pagination += '<h3>' + browseByVClass.pageString + '</h3>';
        pagination += '<ul>';
        $.each(pages, function(i, item) {
            var anchorOpen = '<a class="round" href="#" title="' + browseByVClass.viewPageString + ' ' 
            + pages[i].text + ' '
            + browseByVClass.ofTheResults + ' " data-page="'+ pages[i].index +'">';
            var anchorClose = '</a>';
            
            pagination += '<li class="round';
            // Test for active page
            if ( pages[i].text == page) {
                pagination += ' selected';
                anchorOpen = "";
                anchorClose = "";
            }
            pagination += '" role="listitem">';
            pagination += anchorOpen;
            pagination += pages[i].text;
            pagination += anchorClose;
            pagination += '</li>';
        })
        pagination += '</ul>';
        
        // Add the pagination above and below the list of individuals and call the listener
        browseByVClass.individualsContainer.prepend(pagination);
        browseByVClass.individualsContainer.append(pagination);
        browseByVClass.paginationListener();
    },
    
    // Toggle the active class so it's clear which is selected
    selectedVClass: function(vclassUri) {
        // Remove active class on all vClasses
        $('#browse-classes li a.selected').removeClass('selected');
        
        // Add active class for requested vClass
        $('#browse-classes li a[data-uri="'+ vclassUri +'"]').addClass('selected');
    },

    // Toggle the active letter so it's clear which is selected
    selectedAlpha: function(alpha) {
        // if no alpha argument sent, assume all
        if ( alpha == null ) {
            alpha = "all";
        }
        // Remove active class on all letters
        $('#alpha-browse-individuals li a.selected').removeClass('selected');
        
        // Add active class for requested alpha
        $('#alpha-browse-individuals li a[data-alpha="'+ alpha +'"]').addClass('selected');
        
        return alpha;
    },
    
    // Wipe the currently displayed individuals, no-content message, and existing pagination
    wipeSlate: function() {
        browseByVClass.individualsInVClass.empty();
        $('p.no-individuals').remove();
        $('.pagination').remove();
    },
    
    // When no individuals are returned for the AJAX request, print a reasonable message for the user
    emptyResultSet: function(vclass, alpha, filter_bool) {
        var nothingToSeeHere;
        
        this.wipeSlate();
        var alpha = this.selectedAlpha(alpha);
        
        if (filter_bool)
        {
            if ( alpha != "all" ) {
                nothingToSeeHere = '<p class="no-individuals">' + browseByVClass.thereAreNo + ' ' + vclass.name + browseByVClass.withTheseSelectedFilters + ' ' + browseByVClass.indNamesStartWithFilter + ' <em>'+ alpha.toUpperCase() +'</em>' + '.</p> <p class="no-individuals">' + browseByVClass.plsChangeSelection + '</p>';
            } else {
                nothingToSeeHere = '<p class="no-individuals">' + browseByVClass.thereAreNo + ' ' + vclass.name + browseByVClass.withTheseSelectedFilters + '.' + '</p> <p class="no-individuals">' + browseByVClass.plsChangeSelection + '</p>' ;
            }
        } else {
            if ( alpha != "all" ) {
                nothingToSeeHere = '<p class="no-individuals">' + browseByVClass.thereAreNo + ' ' + vclass.name + ' ' + browseByVClass.indNamesStartWith + ' <em>'+ alpha.toUpperCase() +'</em>.</p> <p class="no-individuals">' + browseByVClass.tryAnotherLetter + '</p>';
            } else {
                nothingToSeeHere = '<p class="no-individuals">' + browseByVClass.thereAreNo + ' ' + vclass.name + ' ' + browseByVClass.indsInSystem + '</p> <p class="no-individuals">' + browseByVClass.selectAnotherClass + '</p>';
            }
        }

        browseByVClass.individualsContainer.prepend(nothingToSeeHere);   
    },
  
    ajaxStart: function() { 
        $body = $("body");
        $body.addClass("loading");    },
    ajaxStop: function() {
        $body = $("body");
        $body.removeClass("loading"); }    
};

$(document).ready(function() {
    browseByVClass.onLoad();
});