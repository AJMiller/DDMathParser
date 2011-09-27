# DDMathParser

You have an `NSString`.  You want an `NSNumber`.  Previously, you would have to rely on [abusing `NSPredicate`](http://tumblr.com/xqopow93r) to turn your string into an `NSExpression` that you could then evaluate.  However, this has a major flaw:  extending it to support functions that aren't built-in to `NSExpression` provided for some awkward syntax.  So if you really need `sin()`, you have to jump through some intricate hoops to get it.

You could also have used [`GCMathParser`](http://apptree.net/parser.htm).  This, however, isn't extensible at all.  So if you really need `stddev()` or `nthroot()` functions, you're out of luck.

Thus, `DDMathParser`.  It is written to be identical to `NSExpression` in all the ways that matter, but with the major addition that you can define new functions as you need.

## Documentation

Please see [the DDMathParser wiki](https://github.com/davedelong/DDMathParser/wiki) for up-to-date documentation.

## Compatibility

`DDMathParser` requires blocks, so therefore is only compatible with iOS 4+ and Mac OS X 10.6+.

Though it has not been tested, `DDMathParser` should be fully compatible with garbage collected applications.

## License

Copyright (c) 2010-2011 Dave DeLong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.