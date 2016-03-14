---
title: Section 7 Compliance Exploration
subtitle: 'Preliminary analyses'
author: 'Jacob Malcom, Defenders of Wildlife, and Tiffany Kim, University of Maryland'
output: 
    tufte::tufte_html
---



# Background

<span class="newthought">Section 7 of the U.S. Endangered Species Act (ESA)</span>^[http://www.nmfs.noaa.gov/pr/pdfs/laws/esa_section7.pdf] directs federal agencies to use their authority to further the conservation of ESA-listed species. One way they do that is by "consulting" with the U.S. Fish and Wildlife Service or the National Marine Fisheries Service if an action they permit, fund, or carry out may affect listed species. While section 7 may be the strongest part of the ESA, it is difficult to determine if the section is living up to its full potential because there is no information about whether agencies are complying with the terms of the consultations. 

One possibly efficient solution to the challenge of monitoring compliance is using remotely sensed data, e.g., satellite and aerial imagery. Building off of our section 7 database^[[Malcom and Li 2015 (PNAS)](http://www.pnas.org/content/112/52/15844.abstract)], we randomly selected hundreds of consultations to investigate more deeply. We have two primary goals with this work:

1. Estimate the rate at which we can identify the (likely) action site given information in the section 7 database; and
2. If the action site is found, estimate the area of habitat loss, which will allow us to estimate the total acreage of habitat lost under section 7.

This is a preliminary analysis of the data that TK has collected. The code that generated this document ("prelim\_report\_v0-1.Rmd") contains all of the code needed to run the analyses presented herein.






# Plots and such

First we compare the distribution of whether we expected to see something to the rate at which we actually saw something. First, the formal consultations:

<div class="figure">
<p class="caption">**Expected (left) and observed (right) observabilitites given the work types of selected _formal_ consultations.**</p><img src="test_report_files/figure-html/fig-1-1.png" alt="**Expected (left) and observed (right) observabilitites given the work types of selected _formal_ consultations.**"  /></div>

On the left we have the "Expected", and our (mine and Tiffany's consensus) suggested there might be a lot of consultations we weren't sure if we would see (0.5). After collecting data on 142 consultations, the vast majority of our uncertainties were not visible.

And now the informal consultations:

<div class="figure">
<p class="caption">**Expected (left) and observed (right) observabilitites given the work types of selected _informal_ consultations.**</p><img src="test_report_files/figure-html/fig-2-1.png" alt="**Expected (left) and observed (right) observabilitites given the work types of selected _informal_ consultations.**"  /></div>

For the 50 informal consultations evaluated so far, we expected more in the "will see" category (1; ~22). But we end up losing a few, and see more unobservable.


## Observability by Work Category

Next, we would like to know how variable detectability is within work categories. It may be that some work categories are particularly amenable to remote sensing but others are not.



<div class="figure fullwidth">
<img src="test_report_files/figure-html/fig-4-1.png" alt="**Violin-and-point plot of observability of _formal_ (left) and _informal_ (right) consultations by work category.** Points near the 1 line are were observed; 0.5 were possible detections; and 0 were not detectable. Wider sections of violin plots indicate more data points, which may be partially obscured by overlapping points."  />
<p class="caption marginnote shownote">**Violin-and-point plot of observability of _formal_ (left) and _informal_ (right) consultations by work category.** Points near the 1 line are were observed; 0.5 were possible detections; and 0 were not detectable. Wider sections of violin plots indicate more data points, which may be partially obscured by overlapping points.</p>
</div>

We're able to see actions addressed in _informal_ consultations consistently for a few work categories (dots at 1 on y-axis), but many consultations are not visible from imagery (at 0), or we're not sure (at 0.5). Note that the work categories are different than formal consultation categories.

## Sidetrack #1

What is the distribution of earliest images available across the sites evaluated?


```
##                  Min.               1st Qu.                Median 
## "1939-12-01 00:00:00" "1993-04-08 12:00:00" "1993-07-16 12:00:00" 
##                  Mean               3rd Qu.                  Max. 
## "1991-08-07 06:34:31" "1994-09-01 00:00:00" "2005-03-01 00:00:00"
```

<div class="figure">
<p class="caption">The distribution of the earliest images available through Google Earth Pro (R) at sites evaluated during section 7 consultation.</p><img src="test_report_files/figure-html/fig-5-1.png" alt="The distribution of the earliest images available through Google Earth Pro (R) at sites evaluated during section 7 consultation."  /></div>

If so desired, we can go back to ca. 1940 in some areas to measure how much habitat has changed over 65 years. But, given this initial data, most of the time we'll only be able to go back to ca. 1992.

## On-track: What are observability rates?



_Formal consultation observabilities (overall)_

```
## Observability:
## 	 0.391797110174594 
## # consultations in set:
## 	 1661 
## # consultations we expect to see effects:
## 	 650.775
```

_Informal consultation observabilities (overall)_

```
## Observability:
## 	 0.351479012345679 
## # consultations in set:
## 	 20250 
## # consultations we expect to see effects:
## 	 7117.45
```

35-39% observability isn't great...I think we need to see how the number of consultations per work type^[Work "type" is a finer categorization than work "category".] compares to the observability.







<div class="figure fullwidth">
<img src="test_report_files/figure-html/fig-6-1.png" alt="**Observability vs. number of _formal_ consultations by work type.** Each point is the mean observability of that work type."  />
<p class="caption marginnote shownote">**Observability vs. number of _formal_ consultations by work type.** Each point is the mean observability of that work type.</p>
</div>

<div class="figure fullwidth">
<img src="test_report_files/figure-html/fig-7-1.png" alt="**Observability vs. number of _informal_ consultations by work type.** Each point is the mean observability of that work type."  />
<p class="caption marginnote shownote">**Observability vs. number of _informal_ consultations by work type.** Each point is the mean observability of that work type.</p>
</div>

__*It's unfortunate that the labels overlap as much as they do, but without making a dynamic figure, this is the best I think we can hope for.*__


## Total area

Per Goal 2, we would like to say something about the total area of habitat that has been "given away" under section 7. Even though the sample sizes are relatively small at this point, we can bootstrap sample^[Bootstrapping is simply taking a random sample from among a starting dataset to calculate a particular statistic (in this case, the sum of areas) many times. From these samples we can get an estimated distribution of the statistic.] from the areas that TK has measured and get a distribution of estimated areas affected. First the formal consultations:




```r
bootstrap_total_area(form_dat, B=1000, N=6829)
```

<img src="test_report_files/figure-html/unnamed-chunk-12-1.png" title="" alt=""  />

```
## [1] "Mean: 121148.67393"
## [1] "95% CI: 113175.02 - 128857.945"
```

So about 120,000 acres for formal consultations...


```r
bootstrap_total_area(inform_dat, B=1000, N=81461)
```

<img src="test_report_files/figure-html/unnamed-chunk-13-1.png" title="" alt=""  />

```
## [1] "Mean: 939328.77108"
## [1] "95% CI: 928502.7215 - 950408.8125"
```

...and about 940,000 acres for informal consultations (!).


# Discussion

This is only a preliminary analysis, but the results suggest a few interesting items.

1. There are likely a large number of actions evaluated under section 7 for which aerial imagery isn't going to work very well. A few work categories in particular might be warranted, but we aren't going to be able to monitor compliance of even a majority of actions.
2. The preliminary estimates of the total area of habitat lost under section 7 suggests that the situation isn't good. Over 1,000,000 acres since 2008!
3. But this really begs the question, _How much habitat was lost from 2008-2015 across the entire US?_ (Detractors of the ESA claims that it "kills the economy". If it turns out that consultations account for a small percentage of the total habitat lost (a measure of economic output) then their claims are clearly bogus.)
  
There will be much more, later.

<hr style='float: left; width:60%'>

_Any views expressed in this working paper are not necessarily the views of Defenders of Wildlife. This document is nothing more than a working paper, tracking work in progress._

<div style='text-align:center'>
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a>
<br/>
This <span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/InteractiveResource" rel="dct:type">work</span> by <a xmlns:cc="http://creativecommons.org/ns" href="http://defenders.org" property="cc:attributionName" rel="cc:attributionURL">Defenders of Wildlife</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
</div>
