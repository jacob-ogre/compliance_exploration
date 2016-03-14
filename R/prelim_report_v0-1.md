---
title: Section 7 Compliance Exploration
author: 'Jacob Malcom, Defenders of Wildlife'
output: 
    md_document
---
Preliminary analysis
====================

This is a preliminary analysis of the data that Tiffany Kim has
collected for evaluating how often remotely sensed imagery can be used
to check for compliance with section 7 of the US Endangered Species Act.
The code that generated this document (`prelim_report_v0-1.Rmd`)
contains all of the code needed to run the analyses presented herein.

Plots and such
--------------

First, let's compare the distribution of whether we expected to see
something to the rate at which we actually saw something. First, the
formal consultations:

    make_expect_obs_hist(form_dat)

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-9-1.png)<!-- -->![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-9-2.png)<!-- -->

On the left we have the "Expected", and our (mine and Tiffany's
consensus) suggested there might be a lot of consultations we weren't
sure if we would see (0.5). After collecting data on 142 consultations,
the vast majority of our uncertainties were not visible (right plot).

*And now* the informal consultations:

    make_expect_obs_hist(inform_dat)

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-10-1.png)<!-- -->![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-10-2.png)<!-- -->

For the 50 informal consultations evaluated so far, we expected more in
the "will see" category (1; ~22). But we end up losing a few, and see
more unobservable.

------------------------------------------------------------------------

Now let's look by work cat and type
-----------------------------------

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-12-1.png)<!-- -->

------------------------------------------------------------------------

Sidetrack \#1
-------------

What is the distribution of earliest images available across the sites
evaluated?

    mean(form_dat$earliest_date, na.rm = T)

    ## [1] "1991-08-07 06:34:31 UTC"

    median(form_dat$earliest_date, na.rm = T)

    ## [1] "1993-07-16 12:00:00 UTC"

    summary(form_dat$earliest_date, na.rm = T)

    ##                  Min.               1st Qu.                Median 
    ## "1939-12-01 00:00:00" "1993-04-08 12:00:00" "1993-07-16 12:00:00" 
    ##                  Mean               3rd Qu.                  Max. 
    ## "1991-08-07 06:34:31" "1994-09-01 00:00:00" "2005-03-01 00:00:00"

    ggplot(combo_dat, aes(earliest_date)) +
        geom_histogram() +
        labs(x = "Earliest Aerial Image Date") +
        theme_hc()

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

    ## Warning: Removed 1 rows containing non-finite values (stat_bin).

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-14-1.png)<!-- -->

------------------------------------------------------------------------

On-track: What are observability rates?
---------------------------------------

    get_observabilities(form_dat, "formal")

    ## Observability:
    ##   0.391797110174594 
    ## # consultations in set:
    ##   1661 
    ## # consultations we expect to see effects:
    ##   650.775

    get_observabilities(inform_dat, "informal")

    ## Observability:
    ##   0.351479012345679 
    ## # consultations in set:
    ##   20250 
    ## # consultations we expect to see effects:
    ##   7117.45

35-39% observability isn't great...

I think we need to see how the number of consultations per work category
compares to the observability

    plot_observability_vs_available(form_obs_dat)

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-21-1.png)<!-- -->

    plot_observability_vs_available(inform_obs_dat)

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-22-1.png)<!-- -->

***I think the conclusion is that there are many consultations for which
we will never or only rarely have a chance of seeing anything using
aerial imagery.***

(Note: I wish I could use speech-to-text for these comments!)

------------------------------------------------------------------------

Total area
----------

Ultimately we would like to say something about the total area of
habitat that has been "given away" under section 7. Even though the
sample sizes are relatively small at this point, we can bootstrap sample
from the areas that Tiffany has measured and get a distribution of
estimated areas affected!

    bootstrap_total_area(form_dat, B=1000, N=6829)

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-24-1.png)<!-- -->

    ## [1] 121090.7
    ##     2.5%    97.5% 
    ## 113163.6 128819.0

So about 120,000 acres for formal consultations...

    bootstrap_total_area(inform_dat, B=1000, N=81461)

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](prelim_report_v0-1_files/figure-markdown_strict/unnamed-chunk-25-1.png)<!-- -->

    ## [1] 939335.8
    ##     2.5%    97.5% 
    ## 926839.9 950773.2

...and about 940,000 acres for informal consultations (!).

------------------------------------------------------------------------

Discussion
----------

This is only a preliminary analysis, but the results suggest a few
interesting items.

1.  There are likely a large number of actions evaluated under section 7
    for which aerial imagery isn't going to work very well. A few work
    categories in particular might be warranted, but we aren't going to
    be able to monitor compliance of even a majority of actions.
2.  The preliminary estimates of the total area of habitat lost under
    section 7 suggests that the situation isn't good. Over 1,000,000
    acres since 2008!
3.  But this really begs the question, *How much habitat was lost from
    2008-2015 across the entire US?*

-   Detractors of the ESA claims that it "kills the economy". If it
    turns out that consultation - either informal or formal - accounts
    for a small percentage of the total habitat lost (a measure of
    economic output) then their claims are *clearly* bogus.

There will be much more, later.
