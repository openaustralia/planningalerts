[Help improve this page](https://github.com/openaustralia/planningalerts-app/blob/master/app/views/atdis/_guidance.md)

If you are planning to submit your development application feed for ATDIS compliance testing this is the page for you! Here we'll outline what you need to do to prepare yourself to ensure maximum chance of success. We will guide you step-by-step through the testing you should do yourself before submitting your feed for compliance testing.

These are the same steps which the [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au) (OAF) will carry out for the official compliance testing.

Note that the definitive reference of what is compliant with the ATDIS specification is the [specification document](specification) itself. This page is intended as a short, simple to read summary of the process by which OAF will test compliance and you should test your compliance before submitting. Just because something isn’t included here (and is included in the specification) doesn’t mean that it isn’t important.

###<a name="before-submitting"></a> What you should do to prepare before submitting for compliance testing

Follow the 8 steps below.

####<a name="step-1"></a> Step 1 - Test your feed against the automated test harness

Before submitting your ATDIS feed for compliance testing you should thoroughly test your ATDIS feed using the automated test harness available at:

[http://www.planningalerts.org.au/atdis/test](http://www.planningalerts.org.au/atdis/test)

* If there are multiple pages of results, test each page
* Test that different ways of searching across applications all validate

**If you've passed, congratulations! You've passed the first step.**

It’s really important to understand that passing the automated test is the first step and does not guarantee that your feed is compliant. There are many aspects of the specification that can not be easily tested automatically and so are not included in the test harness. These will be covered in the following steps.

####<a name="step-2"></a> Step 2 - Manual inspection of results

Go back to the test harness results in step 1 and very carefully examine the development application data that's returned, looking for any:

* Inconsistencies
* Text description information that looks garbled or malformed
* Dummy data that is clearly wrong
* Repeated information that shouldn't be repeated

####<a name="step-3"></a> Step 3 - Manual inspection of paging

If your feed returns multiple pages of results do the same manual inspection as you did in step 2 for each of the pages. Also, make sure that the pages are returning different results and check that they are ordered as expected.

####<a name="step-4"></a> Step 4 - Manual inspection of results of different filtering

With the [test harness](http://www.planningalerts.org.au/atdis/test) you can easily test your feed's response to different kinds of searches (filtering). Test that the following searches work and return the expected results:

* Lodgement date (from and/or to)
* Last modified date (from and/or to)
* Street names (one or more)
* Suburbs (one or more)
* Postcodes (one or more)

Make sure you also test combinations of the searches, for instance a search on suburb and street names at the same time.

####<a name="step-5"></a> Step 5 - Test feed URLs for individual applications

Test that each individual application in the feed results can also be accessed individually at its own URL, returning results consistent with those in the main feed.

See [section 4.2](/atdis/specification#section4.2) of the specification for more information about the required feed URL.

####<a name="step-6"></a> Step 6 - Visually inspect `more_info_url` and `comments_url` web addresses

With your web browser follow links in the mandatory `more_info_url` fields and visually inspect them. They should be a normal, human-readable web page giving you more information about that particular application.

Note that, “_[The underlying content must be directly accessible without authentication, cookies or other limiting requirements for the consuming system](http://localhost:3000/atdis/specification#section4.3.2)_”. A good way to test this is to open a “private browsing” or “incognito” window to ensure that you're not logged in or have any cookies from your system present.

Follow any optional `comments_url` links in the same way.

####<a name="step-7"></a> Step 7 - test browser renderable feeds

* Test that pages render valid HTML5 and CSS3
* Test that pages are WCAG2.0 compatible (minimum level A) - Use automated checking tool available at [http://achecker.ca/checker/index.php](http://achecker.ca/checker/index.php)

####<a name="step-8"></a> Step 8 - Submit your feed for compliance testing

When you have completed steps 1-7 successfully you should be ready to submit your feed for compliance testing.

When you are ready please contact xxxxx at NSW Planning & Environment and let them know.

Please provide them with:

* One or more Base URLs of ATDIS feeds (as they would be entered into the test harness)

(For example: http://www.council.nsw.gov.au/atdis/1.0)
