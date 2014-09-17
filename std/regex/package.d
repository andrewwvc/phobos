/++
  $(SECTION Intro)
  $(LUCKY Regular expressions) are a commonly used method of pattern matching
  on strings, with $(I regex) being a catchy word for a pattern in this domain
  specific language. Typical problems usually solved by regular expressions
  include validation of user input and the ubiquitous find & replace
  in text processing utilities.

  $(SECTION Synopsis)
  ---
  import std.regex;
  import std.stdio;
  void main()
  {
      // Print out all possible dd/mm/yy(yy) dates found in user input.
      auto r = regex(r"\b[0-9][0-9]?/[0-9][0-9]?/[0-9][0-9](?:[0-9][0-9])?\b");
      foreach(line; stdin.byLine)
      {
        // matchAll() returns a range that can be iterated
        // to get all subsequent matches.
        foreach(c; matchAll(line, r))
            writeln(c.hit);
      }
  }
  ...

  // Create a static regex at compile-time, which contains fast native code.
  auto ctr = ctRegex!(`^.*/([^/]+)/?$`);

  // It works just like a normal regex:
  auto c2 = matchFirst("foo/bar", ctr);   // First match found here, if any
  assert(!c2.empty);   // Be sure to check if there is a match before examining contents!
  assert(c2[1] == "bar");   // Captures is a range of submatches: 0 = full match.

  ...

  // The result of the $(D matchAll) is directly testable with if/assert/while.
  // e.g. test if a string consists of letters:
  assert(matchFirst("Letter", `^\p{L}+$`));


  ---
  $(SECTION Syntax and general information)
  The general usage guideline is to keep regex complexity on the side of simplicity,
  as its capabilities reside in purely character-level manipulation.
  As such it's ill-suited for tasks involving higher level invariants
  like matching an integer number $(U bounded) in an [a,b] interval.
  Checks of this sort of are better addressed by additional post-processing.

  The basic syntax shouldn't surprise experienced users of regular expressions.
  For an introduction to $(D std.regex) see a
  $(WEB dlang.org/regular-expression.html, short tour) of the module API
  and its abilities.

  There are other web resources on regular expressions to help newcomers,
  and a good $(WEB www.regular-expressions.info, reference with tutorial)
  can easily be found.

  This library uses a remarkably common ECMAScript syntax flavor
  with the following extensions:
  $(UL
    $(LI Named subexpressions, with Python syntax. )
    $(LI Unicode properties such as Scripts, Blocks and common binary properties e.g Alphabetic, White_Space, Hex_Digit etc.)
    $(LI Arbitrary length and complexity lookbehind, including lookahead in lookbehind and vise-versa.)
  )

  $(REG_START Pattern syntax )
  $(I std.regex operates on codepoint level,
    'character' in this table denotes a single Unicode codepoint.)
  $(REG_TABLE
    $(REG_TITLE Pattern element, Semantics )
    $(REG_TITLE Atoms, Match single characters )
    $(REG_ROW any character except [{|*+?()^$, Matches the character itself. )
    $(REG_ROW ., In single line mode matches any character.
      Otherwise it matches any character except '\n' and '\r'. )
    $(REG_ROW [class], Matches a single character
      that belongs to this character class. )
    $(REG_ROW [^class], Matches a single character that
      does $(U not) belong to this character class.)
    $(REG_ROW \cC, Matches the control character corresponding to letter C)
    $(REG_ROW \xXX, Matches a character with hexadecimal value of XX. )
    $(REG_ROW \uXXXX, Matches a character  with hexadecimal value of XXXX. )
    $(REG_ROW \U00YYYYYY, Matches a character with hexadecimal value of YYYYYY. )
    $(REG_ROW \f, Matches a formfeed character. )
    $(REG_ROW \n, Matches a linefeed character. )
    $(REG_ROW \r, Matches a carriage return character. )
    $(REG_ROW \t, Matches a tab character. )
    $(REG_ROW \v, Matches a vertical tab character. )
    $(REG_ROW \d, Matches any Unicode digit. )
    $(REG_ROW \D, Matches any character except Unicode digits. )
    $(REG_ROW \w, Matches any word character (note: this includes numbers).)
    $(REG_ROW \W, Matches any non-word character.)
    $(REG_ROW \s, Matches whitespace, same as \p{White_Space}.)
    $(REG_ROW \S, Matches any character except those recognized as $(I \s ). )
    $(REG_ROW \\, Matches \ character. )
    $(REG_ROW \c where c is one of [|*+?(), Matches the character c itself. )
    $(REG_ROW \p{PropertyName}, Matches a character that belongs
        to the Unicode PropertyName set.
      Single letter abbreviations can be used without surrounding {,}. )
    $(REG_ROW  \P{PropertyName}, Matches a character that does not belong
        to the Unicode PropertyName set.
      Single letter abbreviations can be used without surrounding {,}. )
    $(REG_ROW \p{InBasicLatin}, Matches any character that is part of
          the BasicLatin Unicode $(U block).)
    $(REG_ROW \P{InBasicLatin}, Matches any character except ones in
          the BasicLatin Unicode $(U block).)
    $(REG_ROW \p{Cyrillic}, Matches any character that is part of
        Cyrillic $(U script).)
    $(REG_ROW \P{Cyrillic}, Matches any character except ones in
        Cyrillic $(U script).)
    $(REG_TITLE Quantifiers, Specify repetition of other elements)
    $(REG_ROW *, Matches previous character/subexpression 0 or more times.
      Greedy version - tries as many times as possible.)
    $(REG_ROW *?, Matches previous character/subexpression 0 or more times.
      Lazy version  - stops as early as possible.)
    $(REG_ROW +, Matches previous character/subexpression 1 or more times.
      Greedy version - tries as many times as possible.)
    $(REG_ROW +?, Matches previous character/subexpression 1 or more times.
      Lazy version  - stops as early as possible.)
    $(REG_ROW {n}, Matches previous character/subexpression exactly n times. )
    $(REG_ROW {n&#44}, Matches previous character/subexpression n times or more.
      Greedy version - tries as many times as possible. )
    $(REG_ROW {n&#44}?, Matches previous character/subexpression n times or more.
      Lazy version - stops as early as possible.)
    $(REG_ROW {n&#44m}, Matches previous character/subexpression n to m times.
      Greedy version - tries as many times as possible, but no more than m times. )
    $(REG_ROW {n&#44m}?, Matches previous character/subexpression n to m times.
      Lazy version - stops as early as possible, but no less then n times.)
    $(REG_TITLE Other, Subexpressions & alternations )
    $(REG_ROW (regex),  Matches subexpression regex,
      saving matched portion of text for later retrieval. )
    $(REG_ROW (?:regex), Matches subexpression regex,
      $(U not) saving matched portion of text. Useful to speed up matching. )
    $(REG_ROW A|B, Matches subexpression A, or failing that, matches B. )
    $(REG_ROW (?P&lt;name&gt;regex), Matches named subexpression
        regex labeling it with name 'name'.
        When referring to a matched portion of text,
        names work like aliases in addition to direct numbers.
     )
    $(REG_TITLE Assertions, Match position rather than character )
    $(REG_ROW ^, Matches at the begining of input or line (in multiline mode).)
    $(REG_ROW $, Matches at the end of input or line (in multiline mode). )
    $(REG_ROW \b, Matches at word boundary. )
    $(REG_ROW \B, Matches when $(U not) at word boundary. )
    $(REG_ROW (?=regex), Zero-width lookahead assertion.
        Matches at a point where the subexpression
        regex could be matched starting from the current position.
      )
    $(REG_ROW (?!regex), Zero-width negative lookahead assertion.
        Matches at a point where the subexpression
        regex could $(U not) be matched starting from the current position.
      )
    $(REG_ROW (?<=regex), Zero-width lookbehind assertion. Matches at a point
        where the subexpression regex could be matched ending
        at the current position (matching goes backwards).
      )
    $(REG_ROW  (?<!regex), Zero-width negative lookbehind assertion.
      Matches at a point where the subexpression regex could $(U not)
      be matched ending at the current position (matching goes backwards).
     )
  )

  $(REG_START Character classes )
  $(REG_TABLE
    $(REG_TITLE Pattern element, Semantics )
    $(REG_ROW Any atom, Has the same meaning as outside of a character class.)
    $(REG_ROW a-z, Includes characters a, b, c, ..., z. )
    $(REG_ROW [a||b]&#44 [a--b]&#44 [a~~b]&#44 [a&&b], Where a, b are arbitrary classes,
     means union, set difference, symmetric set difference, and intersection respectively.
     $(I Any sequence of character class elements implicitly forms a union.) )
  )

  $(REG_START Regex flags )
  $(REG_TABLE
    $(REG_TITLE Flag, Semantics )
    $(REG_ROW g, Global regex, repeat over the whole input. )
    $(REG_ROW i, Case insensitive matching. )
    $(REG_ROW m, Multi-line mode, match ^, $ on start and end line separators
       as well as start and end of input.)
    $(REG_ROW s, Single-line mode, makes . match '\n' and '\r' as well. )
    $(REG_ROW x, Free-form syntax, ignores whitespace in pattern,
      useful for formatting complex regular expressions. )
  )

  $(SECTION Unicode support)

  This library provides full Level 1 support* according to
    $(WEB unicode.org/reports/tr18/, UTS 18). Specifically:
  $(UL
    $(LI 1.1 Hex notation via any of \uxxxx, \U00YYYYYY, \xZZ.)
    $(LI 1.2 Unicode properties.)
    $(LI 1.3 Character classes with set operations.)
    $(LI 1.4 Word boundaries use the full set of "word" characters.)
    $(LI 1.5 Using simple casefolding to match case
        insensitively across the full range of codepoints.)
    $(LI 1.6 Respecting line breaks as any of
        \u000A | \u000B | \u000C | \u000D | \u0085 | \u2028 | \u2029 | \u000D\u000A.)
    $(LI 1.7 Operating on codepoint level.)
  )
  *With exception of point 1.1.1, as of yet, normalization of input
    is expected to be enforced by user.

    $(SECTION Replace format string)

    A set of functions in this module that do the substitution rely
    on a simple format to guide the process. In particular the table below
    applies to the $(D format) argument of
    $(LREF replaceFirst) and $(LREF replaceAll).

    The format string can reference parts of match using the following notation.
    $(REG_TABLE
        $(REG_TITLE Format specifier, Replaced by )
        $(REG_ROW $&amp;, the whole match. )
        $(REG_ROW $`, part of input $(I preceding) the match. )
        $(REG_ROW $', part of input $(I following) the match. )
        $(REG_ROW $$, '$' character. )
        $(REG_ROW \c &#44 where c is any character, the character c itself. )
        $(REG_ROW \\, '\' character. )
        $(REG_ROW &#36;1 .. &#36;99, submatch number 1 to 99 respectively. )
    )

  $(SECTION Slicing and zero memory allocations orientation)

  All matches returned by pattern matching functionality in this library
    are slices of the original input. The notable exception is the $(D replace)
    family of functions  that generate a new string from the input.

    In cases where producing the replacement is the ultimate goal
    $(LREF replaceFirstInto) and $(LREF replaceAllInto) could come in handy
    as functions that  avoid allocations even for replacement.

    Copyright: Copyright Dmitry Olshansky, 2011-

  License: $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).

  Authors: Dmitry Olshansky,

    API and utility constructs are modeled after the original $(D std.regex)
  by Walter Bright and Andrei Alexandrescu.

  Source: $(PHOBOSSRC std/_regex.d)

Macros:
    REG_ROW = $(TR $(TD $(I $1 )) $(TD $+) )
    REG_TITLE = $(TR $(TD $(B $1)) $(TD $(B $2)) )
    REG_TABLE = <table border="1" cellspacing="0" cellpadding="5" > $0 </table>
    REG_START = <h3><div align="center"> $0 </div></h3>
    SECTION = <h3><a id="$1">$0</a></h3>
    S_LINK = <a href="#$1">$+</a>
 +/
module std.regex;

import std.regex.internal.ir;
import std.regex.internal.thompson; //TODO: get rid of this dependency
import std.exception, std.traits, std.range;

/++
    $(D Regex) object holds regular expression pattern in compiled form.

    Instances of this object are constructed via calls to $(D regex).
    This is an intended form for caching and storage of frequently
    used regular expressions.

    Examples:

    Test if this object doesn't contain any compiled pattern.
    ---
    Regex!char r;
    assert(r.empty);
    r = regex(""); // Note: "" is a valid regex pattern.
    assert(!r.empty);
    ---

    Getting a range of all the named captures in the regex.
    ----
    import std.range;
    import std.algorithm;

    auto re = regex(`(?P<name>\w+) = (?P<var>\d+)`);
    auto nc = re.namedCaptures;
    static assert(isRandomAccessRange!(typeof(nc)));
    assert(!nc.empty);
    assert(nc.length == 2);
    assert(nc.equal(["name", "var"]));
    assert(nc[0] == "name");
    assert(nc[1..$].equal(["var"]));

+/
public alias Regex(Char) = std.regex.internal.ir.Regex!(Char);

/++
    A $(D StaticRegex) is $(D Regex) object that contains D code specially
    generated at compile-time to speed up matching.

    Implicitly convertible to normal $(D Regex),
    however doing so will result in losing this additional capability.
+/
public alias StaticRegex(Char) = std.regex.internal.ir.StaticRegex!(Char);

/++
    Compile regular expression pattern for the later execution.
    Returns: $(D Regex) object that works on inputs having
    the same character width as $(D pattern).

    Params:
    pattern = Regular expression
    flags = The _attributes (g, i, m and x accepted)

    Throws: $(D RegexException) if there were any errors during compilation.
+/
@trusted public auto regex(S)(S pattern, const(char)[] flags="")
    if(isSomeString!(S))
{
    import std.functional;
    enum cacheSize = 8; //TODO: invent nice interface to control regex caching
    if(__ctfe)
        return regexImpl(pattern, flags);
    return memoize!(regexImpl!S, cacheSize)(pattern, flags);
}

public auto regexImpl(S)(S pattern, const(char)[] flags="")
    if(isSomeString!(S))
{
    import std.regex.internal.parser;
    auto parser = Parser!(Unqual!(typeof(pattern)))(pattern, flags);
    auto r = parser.program;
    return r;
}


template ctRegexImpl(alias pattern, string flags=[])
{
    import std.regex.internal.parser, std.regex.internal.backtracking;
    enum r = regex(pattern, flags);
    alias Char = BasicElementOf!(typeof(pattern));
    enum source = ctGenRegExCode(r);
    alias Matcher = BacktrackingMatcher!(true);
    @trusted bool func(ref Matcher!Char matcher)
    {
        debug(std_regex_ctr) pragma(msg, source);
        mixin(source);
    }
    enum nr = StaticRegex!Char(r, &func);
}

/++
    Compile regular expression using CTFE
    and generate optimized native machine code for matching it.

    Returns: StaticRegex object for faster matching.

    Params:
    pattern = Regular expression
    flags = The _attributes (g, i, m and x accepted)
+/
public enum ctRegex(alias pattern, alias flags=[]) = ctRegexImpl!(pattern, flags).nr;

enum isRegexFor(RegEx, R) = is(RegEx == Regex!(BasicElementOf!R))
     || is(RegEx == StaticRegex!(BasicElementOf!R));


/++
    $(D Captures) object contains submatches captured during a call
    to $(D match) or iteration over $(D RegexMatch) range.

    First element of range is the whole match.
+/
@trusted public struct Captures(R, DIndex = size_t)
    if(isSomeString!R)
{//@trusted because of union inside
    alias DataIndex = DIndex;
    alias String = R;
private:
    import std.conv;
    R _input;
    bool _empty;
    enum smallString = 3;
    union
    {
        Group!DataIndex[] big_matches;
        Group!DataIndex[smallString] small_matches;
    }
    uint _f, _b;
    uint _ngroup;
    NamedGroup[] _names;

    this()(R input, uint ngroups, NamedGroup[] named)
    {
        _input = input;
        _ngroup = ngroups;
        _names = named;
        newMatches();
        _b = _ngroup;
        _f = 0;
    }

    this(alias Engine)(ref RegexMatch!(R,Engine) rmatch)
    {
        _input = rmatch._input;
        _ngroup = rmatch._engine.re.ngroup;
        _names = rmatch._engine.re.dict;
        newMatches();
        _b = _ngroup;
        _f = 0;
    }

    @property Group!DataIndex[] matches()
    {
       return _ngroup > smallString ? big_matches : small_matches[0 .. _ngroup];
    }

    void newMatches()
    {
        if(_ngroup > smallString)
            big_matches = new Group!DataIndex[_ngroup];
    }

public:
    ///Slice of input prior to the match.
    @property R pre()
    {
        return _empty ? _input[] : _input[0 .. matches[0].begin];
    }

    ///Slice of input immediately after the match.
    @property R post()
    {
        return _empty ? _input[] : _input[matches[0].end .. $];
    }

    ///Slice of matched portion of input.
    @property R hit()
    {
        assert(!_empty);
        return _input[matches[0].begin .. matches[0].end];
    }

    ///Range interface.
    @property R front()
    {
        assert(!empty);
        return _input[matches[_f].begin .. matches[_f].end];
    }

    ///ditto
    @property R back()
    {
        assert(!empty);
        return _input[matches[_b - 1].begin .. matches[_b - 1].end];
    }

    ///ditto
    void popFront()
    {
        assert(!empty);
        ++_f;
    }

    ///ditto
    void popBack()
    {
        assert(!empty);
        --_b;
    }

    ///ditto
    @property bool empty() const { return _empty || _f >= _b; }

    ///ditto
    R opIndex()(size_t i) /*const*/ //@@@BUG@@@
    {
        assert(_f + i < _b,text("requested submatch number ", i," is out of range"));
        assert(matches[_f + i].begin <= matches[_f + i].end,
            text("wrong match: ", matches[_f + i].begin, "..", matches[_f + i].end));
        return _input[matches[_f + i].begin .. matches[_f + i].end];
    }

    /++
        Explicit cast to bool.
        Useful as a shorthand for !(x.empty) in if and assert statements.

        ---
        import std.regex;

        assert(!matchFirst("nothing", "something"));
        ---
    +/

    @safe bool opCast(T:bool)() const nothrow { return !empty; }

    /++
        Lookup named submatch.

        ---
        import std.regex;
        import std.range;

        auto c = matchFirst("a = 42;", regex(`(?P<var>\w+)\s*=\s*(?P<value>\d+);`));
        assert(c["var"] == "a");
        assert(c["value"] == "42");
        popFrontN(c, 2);
        //named groups are unaffected by range primitives
        assert(c["var"] =="a");
        assert(c.front == "42");
        ----
    +/
    R opIndex(String)(String i) /*const*/ //@@@BUG@@@
        if(isSomeString!String)
    {
        size_t index = lookupNamedGroup(_names, i);
        return _input[matches[index].begin .. matches[index].end];
    }

    ///Number of matches in this object.
    @property size_t length() const { return _empty ? 0 : _b - _f;  }

    ///A hook for compatibility with original std.regex.
    @property ref captures(){ return this; }
}

///
unittest
{
    auto c = matchFirst("@abc#", regex(`(\w)(\w)(\w)`));
    assert(c.pre == "@"); // Part of input preceding match
    assert(c.post == "#"); // Immediately after match
    assert(c.hit == c[0] && c.hit == "abc"); // The whole match
    assert(c[2] == "b");
    assert(c.front == "abc");
    c.popFront();
    assert(c.front == "a");
    assert(c.back == "c");
    c.popBack();
    assert(c.back == "b");
    popFrontN(c, 2);
    assert(c.empty);

    assert(!matchFirst("nothing", "something"));
}

/++
    A regex engine state, as returned by $(D match) family of functions.

    Effectively it's a forward range of Captures!R, produced
    by lazily searching for matches in a given input.

    $(D alias Engine) specifies an engine type to use during matching,
    and is automatically deduced in a call to $(D match)/$(D bmatch).
+/
@trusted public struct RegexMatch(R, alias Engine = ThompsonMatcher)
    if(isSomeString!R)
{
private:
    import core.stdc.stdlib;
    alias Char = BasicElementOf!R;
    alias EngineType = Engine!Char;
    EngineType _engine;
    R _input;
    Captures!(R,EngineType.DataIndex) _captures;
    void[] _memory;//is ref-counted

    this(RegEx)(R input, RegEx prog)
    {
        _input = input;
        immutable size = EngineType.initialMemory(prog)+size_t.sizeof;
        _memory = (enforce(malloc(size))[0..size]);
        scope(failure) free(_memory.ptr);
        *cast(size_t*)_memory.ptr = 1;
        _engine = EngineType(prog, Input!Char(input), _memory[size_t.sizeof..$]);
        static if(is(RegEx == StaticRegex!(BasicElementOf!R)))
            _engine.nativeFn = prog.nativeFn;
        _captures = Captures!(R,EngineType.DataIndex)(this);
        _captures._empty = !_engine.match(_captures.matches);
        debug(std_regex_allocation) writefln("RefCount (ctor): %x %d", _memory.ptr, counter);
    }

    @property ref size_t counter(){ return *cast(size_t*)_memory.ptr; }
public:
    this(this)
    {
        if(_memory.ptr)
        {
            ++counter;
            debug(std_regex_allocation) writefln("RefCount (postblit): %x %d",
                _memory.ptr, *cast(size_t*)_memory.ptr);
        }
    }

    ~this()
    {
        if(_memory.ptr && --*cast(size_t*)_memory.ptr == 0)
        {
            debug(std_regex_allocation) writefln("RefCount (dtor): %x %d",
                _memory.ptr, *cast(size_t*)_memory.ptr);
            free(cast(void*)_memory.ptr);
        }
    }

    ///Shorthands for front.pre, front.post, front.hit.
    @property R pre()
    {
        return _captures.pre;
    }

    ///ditto
    @property R post()
    {
        return _captures.post;
    }

    ///ditto
    @property R hit()
    {
        return _captures.hit;
    }

    /++
        Functionality for processing subsequent matches of global regexes via range interface:
        ---
        import std.regex;
        auto m = matchAll("Hello, world!", regex(`\w+`));
        assert(m.front.hit == "Hello");
        m.popFront();
        assert(m.front.hit == "world");
        m.popFront();
        assert(m.empty);
        ---
    +/
    @property auto front()
    {
        return _captures;
    }

    ///ditto
    void popFront()
    {

        if(counter != 1)
        {//do cow magic first
            counter--;//we abandon this reference
            immutable size = EngineType.initialMemory(_engine.re)+size_t.sizeof;
            _memory = (enforce(malloc(size))[0..size]);
            _engine = _engine.dupTo(_memory[size_t.sizeof..size]);
            counter = 1;//points to new chunk
        }
        //previous _captures can have escaped references from Capture object
        _captures.newMatches();
        _captures._empty = !_engine.match(_captures.matches);
    }

    ///ditto
    auto save(){ return this; }

    ///Test if this match object is empty.
    @property bool empty(){ return _captures._empty; }

    ///Same as !(x.empty), provided for its convenience  in conditional statements.
    T opCast(T:bool)(){ return !empty; }

    /// Same as .front, provided for compatibility with original std.regex.
    @property auto captures(){ return _captures; }

}

private @trusted auto matchOnce(alias Engine, RegEx, R)(R input, RegEx re)
{
    import core.stdc.stdlib;
    alias Char = BasicElementOf!R;
    alias EngineType = Engine!Char;

    size_t size = EngineType.initialMemory(re);
    void[] memory = enforce(malloc(size))[0..size];
    scope(exit) free(memory.ptr);
    auto captures = Captures!(R, EngineType.DataIndex)(input, re.ngroup, re.dict);
    auto engine = EngineType(re, Input!Char(input), memory);
    static if(is(RegEx == StaticRegex!(BasicElementOf!R)))
        engine.nativeFn = re.nativeFn;
    captures._empty = !engine.match(captures.matches);
    return captures;
}

private auto matchMany(alias Engine, RegEx, R)(R input, RegEx re)
{
    re.flags |= RegexOption.global;
    return RegexMatch!(R, Engine)(input, re);
}

unittest
{
    //sanity checks for new API
    auto re = regex("abc");
    assert(!"abc".matchOnce!(ThompsonMatcher)(re).empty);
    assert("abc".matchOnce!(ThompsonMatcher)(re)[0] == "abc");
}


private enum isReplaceFunctor(alias fun, R) =
    __traits(compiles, (Captures!R c) { fun(c); });

// the lowest level - just stuff replacements into the sink
private @trusted void replaceCapturesInto(alias output, Sink, R, T)
        (ref Sink sink, R input, T captures)
    if(isOutputRange!(Sink, dchar) && isSomeString!R)
{
    sink.put(captures.pre);
    // a hack to get around bogus errors, should be simply output(captures, sink)
    // "is a nested function and cannot be accessed from"
    static if(isReplaceFunctor!(output, R))
        sink.put(output(captures)); //"mutator" type of function
    else
        output(captures, sink); //"output" type of function
    sink.put(captures.post);
}

// ditto for a range of captures
private void replaceMatchesInto(alias output, Sink, R, T)
        (ref Sink sink, R input, T matches)
    if(isOutputRange!(Sink, dchar) && isSomeString!R)
{
    size_t offset = 0;
    foreach(cap; matches)
    {
        sink.put(cap.pre[offset .. $]);
        // same hack, see replaceCapturesInto
        static if(isReplaceFunctor!(output, R))
            sink.put(output(cap)); //"mutator" type of function
        else
            output(cap, sink); //"output" type of function
        offset = cap.pre.length + cap.hit.length;
    }
    sink.put(input[offset .. $]);
}

//  a general skeleton of replaceFirst
private R replaceFirstWith(alias output, R, RegEx)(R input, RegEx re)
    if(isSomeString!R && isRegexFor!(RegEx, R))
{
    auto data = matchFirst(input, re);
    if(data.empty)
        return input;
    auto app = appender!(R)();
    replaceCapturesInto!output(app, input, data);
    return app.data;
}

// ditto for replaceAll
// the method parameter allows old API to ride on the back of the new one
private R replaceAllWith(alias output,
        alias method=matchAll, R, RegEx)(R input, RegEx re)
    if(isSomeString!R && isRegexFor!(RegEx, R))
{
    auto matches = method(input, re); //inout(C)[] fails
    if(matches.empty)
        return input;
    auto app = appender!(R)();
    replaceMatchesInto!output(app, input, matches);
    return app.data;
}


/++
    Start matching $(D input) to regex pattern $(D re),
    using Thompson NFA matching scheme.

    The use of this function is $(RED discouraged) - use either of
    $(LREF matchAll) or $(LREF matchFirst).

    Delegating  the kind of operation
    to "g" flag is soon to be phased out along with the
    ability to choose the exact matching scheme. The choice of
    matching scheme to use depends highly on the pattern kind and
    can done automatically on case by case basis.

    Returns: a $(D RegexMatch) object holding engine state after first match.
+/

public auto match(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == Regex!(BasicElementOf!R)))
{
    import std.regex.internal.thompson;
    return RegexMatch!(Unqual!(typeof(input)),ThompsonMatcher)(input, re);
}

///ditto
public auto match(R, String)(R input, String re)
    if(isSomeString!R && isSomeString!String)
{
    import std.regex.internal.thompson;
    return RegexMatch!(Unqual!(typeof(input)),ThompsonMatcher)(input, regex(re));
}

public auto match(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == StaticRegex!(BasicElementOf!R)))
{
    import std.regex.internal.backtracking;
    return RegexMatch!(Unqual!(typeof(input)),BacktrackingMatcher!true)(input, re);
}

/++
    Find the first (leftmost) slice of the $(D input) that
    matches the pattern $(D re). This function picks the most suitable
    regular expression engine depending on the pattern properties.

    $(D re) parameter can be one of three types:
    $(UL
      $(LI Plain string, in which case it's compiled to bytecode before matching. )
      $(LI Regex!char (wchar/dchar) that contains a pattern in the form of
        compiled  bytecode. )
      $(LI StaticRegex!char (wchar/dchar) that contains a pattern in the form of
        compiled native machine code. )
    )

    Returns:
    $(LREF Captures) containing the extent of a match together with all submatches
    if there was a match, otherwise an empty $(LREF Captures) object.
+/
public auto matchFirst(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == Regex!(BasicElementOf!R)))
{
    import std.regex.internal.thompson;
    return matchOnce!ThompsonMatcher(input, re);
}

///ditto
public auto matchFirst(R, String)(R input, String re)
    if(isSomeString!R && isSomeString!String)
{
    import std.regex.internal.thompson;
    return matchOnce!ThompsonMatcher(input, regex(re));
}

public auto matchFirst(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == StaticRegex!(BasicElementOf!R)))
{
    import std.regex.internal.backtracking;
    return matchOnce!(BacktrackingMatcher!true)(input, re);
}

/++
    Initiate a search for all non-overlapping matches to the pattern $(D re)
    in the given $(D input). The result is a lazy range of matches generated
    as they are encountered in the input going left to right.

    This function picks the most suitable regular expression engine
    depending on the pattern properties.

    $(D re) parameter can be one of three types:
    $(UL
      $(LI Plain string, in which case it's compiled to bytecode before matching. )
      $(LI Regex!char (wchar/dchar) that contains a pattern in the form of
        compiled  bytecode. )
      $(LI StaticRegex!char (wchar/dchar) that contains a pattern in the form of
        compiled native machine code. )
    )

    Returns:
    $(LREF RegexMatch) object that represents matcher state
    after the first match was found or an empty one if not present.
+/
public auto matchAll(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == Regex!(BasicElementOf!R)))
{
    import std.regex.internal.thompson;
    return matchMany!ThompsonMatcher(input, re);
}

///ditto
public auto matchAll(R, String)(R input, String re)
    if(isSomeString!R && isSomeString!String)
{
    import std.regex.internal.thompson;
    return matchMany!ThompsonMatcher(input, regex(re));
}

public auto matchAll(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == StaticRegex!(BasicElementOf!R)))
{
    import std.regex.internal.backtracking;
    return matchMany!(BacktrackingMatcher!true)(input, re);
}

// another set of tests just to cover the new API
@system unittest
{
    import std.conv : to;
    import std.algorithm : map, equal;

    foreach(String; TypeTuple!(string, wstring, const(dchar)[]))
    {
        auto str1 = "blah-bleh".to!String();
        auto pat1 = "bl[ae]h".to!String();
        auto mf = matchFirst(str1, pat1);
        assert(mf.equal(["blah".to!String()]));
        auto mAll = matchAll(str1, pat1);
        assert(mAll.equal!((a,b) => a.equal(b))
            ([["blah".to!String()], ["bleh".to!String()]]));

        auto str2 = "1/03/12 - 3/03/12".to!String();
        auto pat2 = regex(r"(\d+)/(\d+)/(\d+)".to!String());
        auto mf2 = matchFirst(str2, pat2);
        assert(mf2.equal(["1/03/12", "1", "03", "12"].map!(to!String)()));
        auto mAll2 = matchAll(str2, pat2);
        assert(mAll2.front.equal(mf2));
        mAll2.popFront();
        assert(mAll2.front.equal(["3/03/12", "3", "03", "12"].map!(to!String)()));
        mf2.popFrontN(3);
        assert(mf2.equal(["12".to!String()]));

        auto ctPat = ctRegex!(`(?P<Quot>\d+)/(?P<Denom>\d+)`.to!String());
        auto str = "2 + 34/56 - 6/1".to!String();
        auto cmf = matchFirst(str, ctPat);
        assert(cmf.equal(["34/56", "34", "56"].map!(to!String)()));
        assert(cmf["Quot"] == "34".to!String());
        assert(cmf["Denom"] == "56".to!String());

        auto cmAll = matchAll(str, ctPat);
        assert(cmAll.front.equal(cmf));
        cmAll.popFront();
        assert(cmAll.front.equal(["6/1", "6", "1"].map!(to!String)()));
    }
}

/++
    Start matching of $(D input) to regex pattern $(D re),
    using traditional $(LUCKY backtracking) matching scheme.

    The use of this function is $(RED discouraged) - use either of
    $(LREF matchAll) or $(LREF matchFirst).

    Delegating  the kind of operation
    to "g" flag is soon to be phased out along with the
    ability to choose the exact matching scheme. The choice of
    matching scheme to use depends highly on the pattern kind and
    can done automatically on case by case basis.

    Returns: a $(D RegexMatch) object holding engine
    state after first match.

+/
public auto bmatch(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == Regex!(BasicElementOf!R)))
{
    import std.regex.internal.backtracking;
    return RegexMatch!(Unqual!(typeof(input)), BacktrackingMatcher!false)(input, re);
}

///ditto
public auto bmatch(R, String)(R input, String re)
    if(isSomeString!R && isSomeString!String)
{
    import std.regex.internal.backtracking;
    return RegexMatch!(Unqual!(typeof(input)), BacktrackingMatcher!false)(input, regex(re));
}

public auto bmatch(R, RegEx)(R input, RegEx re)
    if(isSomeString!R && is(RegEx == StaticRegex!(BasicElementOf!R)))
{
    import std.regex.internal.backtracking;
    return RegexMatch!(Unqual!(typeof(input)),BacktrackingMatcher!true)(input, re);
}

// produces replacement string from format using captures for substitution
package void replaceFmt(R, Capt, OutR)
    (R format, Capt captures, OutR sink, bool ignoreBadSubs = false)
    if(isOutputRange!(OutR, ElementEncodingType!R[]) &&
        isOutputRange!(OutR, ElementEncodingType!(Capt.String)[]))
{
    import std.algorithm, std.conv;
    enum State { Normal, Dollar }
    auto state = State.Normal;
    size_t offset;
L_Replace_Loop:
    while(!format.empty)
        final switch(state)
        {
        case State.Normal:
            for(offset = 0; offset < format.length; offset++)//no decoding
            {
                if(format[offset] == '$')
                {
                    state = State.Dollar;
                    sink.put(format[0 .. offset]);
                    format = format[offset+1 .. $];//ditto
                    continue L_Replace_Loop;
                }
            }
            sink.put(format[0 .. offset]);
            format = format[offset .. $];
            break;
        case State.Dollar:
            if(std.ascii.isDigit(format[0]))
            {
                uint digit = parse!uint(format);
                enforce(ignoreBadSubs || digit < captures.length, text("invalid submatch number ", digit));
                if(digit < captures.length)
                    sink.put(captures[digit]);
            }
            else if(format[0] == '{')
            {
                auto x = find!(a => !std.ascii.isAlpha(a))(format[1..$]);
                enforce(!x.empty && x[0] == '}', "no matching '}' in replacement format");
                auto name = format[1 .. $ - x.length];
                format = x[1..$];
                enforce(!name.empty, "invalid name in ${...} replacement format");
                sink.put(captures[name]);
            }
            else if(format[0] == '&')
            {
                sink.put(captures[0]);
                format = format[1 .. $];
            }
            else if(format[0] == '`')
            {
                sink.put(captures.pre);
                format = format[1 .. $];
            }
            else if(format[0] == '\'')
            {
                sink.put(captures.post);
                format = format[1 .. $];
            }
            else if(format[0] == '$')
            {
                sink.put(format[0 .. 1]);
                format = format[1 .. $];
            }
            state = State.Normal;
            break;
        }
    enforce(state == State.Normal, "invalid format string in regex replace");
}

/++
    Construct a new string from $(D input) by replacing the first match with
    a string generated from it according to the $(D format) specifier.

    To replace all matches use $(LREF replaceAll).

    Params:
    input = string to search
    re = compiled regular expression to use
    format = format string to generate replacements from,
    see $(S_LINK Replace format string, the format string).

    Returns:
    A string of the same type with the first match (if any) replaced.
    If no match is found returns the input string itself.

    Example:
    ---
    assert(replaceFirst("noon", regex("n"), "[$&]") == "[n]oon");
    ---
+/
public R replaceFirst(R, C, RegEx)(R input, RegEx re, const(C)[] format)
    if(isSomeString!R && is(C : dchar) && isRegexFor!(RegEx, R))
{
    return replaceFirstWith!((m, sink) => replaceFmt(format, m, sink))(input, re);
}

/++
    This is a general replacement tool that construct a new string by replacing
    matches of pattern $(D re) in the $(D input). Unlike the other overload
    there is no format string instead captures are passed to
    to a user-defined functor $(D fun) that returns a new string
    to use as replacement.

    This version replaces the first match in $(D input),
    see $(LREF replaceAll) to replace the all of the matches.

    Returns:
    A new string of the same type as $(D input) with all matches
    replaced by return values of $(D fun). If no matches found
    returns the $(D input) itself.

    Example:
    ---
    string list = "#21 out of 46";
    string newList = replaceFirst!(cap => to!string(to!int(cap.hit)+1))
        (list, regex(`[0-9]+`));
    assert(newList == "#22 out of 46");
    ---
+/
public R replaceFirst(alias fun, R, RegEx)(R input, RegEx re)
  if(isSomeString!R && isRegexFor!(RegEx, R))
{
    return replaceFirstWith!((m, sink) => sink.put(fun(m)))(input, re);
}

/++
    A variation on $(LREF replaceFirst) that instead of allocating a new string
    on each call outputs the result piece-wise to the $(D sink). In particular
    this enables efficient construction of a final output incrementally.

    Like in $(LREF replaceFirst) family of functions there is an overload
    for the substitution guided by the $(D format) string
    and the one with the user defined callback.

    Example:
    ---
    import std.array;
    string m1 = "first message\n";
    string m2 = "second message\n";
    auto result = appender!string();
    replaceFirstInto(result, m1, regex(`([a-z]+) message`), "$1");
    //equivalent of the above with user-defined callback
    replaceFirstInto!(cap=>cap[1])(result, m2, regex(`([a-z]+) message`));
    assert(result.data == "first\nsecond\n");
    ---
+/
public @trusted void replaceFirstInto(Sink, R, C, RegEx)
        (ref Sink sink, R input, RegEx re, const(C)[] format)
    if(isOutputRange!(Sink, dchar) && isSomeString!R
        && is(C : dchar) && isRegexFor!(RegEx, R))
    {
    replaceCapturesInto!((m, sink) => replaceFmt(format, m, sink))
        (sink, input, matchFirst(input, re));
    }

///ditto
public @trusted void replaceFirstInto(alias fun, Sink, R, RegEx)
    (Sink sink, R input, RegEx re)
    if(isOutputRange!(Sink, dchar) && isSomeString!R && isRegexFor!(RegEx, R))
{
    replaceCapturesInto!fun(sink, input, matchFirst(input, re));
}

//examples for replaceFirst
@system unittest
{
    import std.conv;
    string list = "#21 out of 46";
    string newList = replaceFirst!(cap => to!string(to!int(cap.hit)+1))
        (list, regex(`[0-9]+`));
    assert(newList == "#22 out of 46");
    import std.array;
    string m1 = "first message\n";
    string m2 = "second message\n";
    auto result = appender!string();
    replaceFirstInto(result, m1, regex(`([a-z]+) message`), "$1");
    //equivalent of the above with user-defined callback
    replaceFirstInto!(cap=>cap[1])(result, m2, regex(`([a-z]+) message`));
    assert(result.data == "first\nsecond\n");
}

/++
    Construct a new string from $(D input) by replacing all of the
    fragments that match a pattern $(D re) with a string generated
    from the match according to the $(D format) specifier.

    To replace only the first match use $(LREF replaceFirst).

    Params:
    input = string to search
    re = compiled regular expression to use
    format = format string to generate replacements from,
    see $(S_LINK Replace format string, the format string).

    Returns:
    A string of the same type as $(D input) with the all
    of the matches (if any) replaced.
    If no match is found returns the input string itself.

    Example:
    ---
    // Comify a number
    auto com = regex(r"(?<=\d)(?=(\d\d\d)+\b)","g");
    assert(replaceAll("12000 + 42100 = 54100", com, ",") == "12,000 + 42,100 = 54,100");
    ---
+/
public @trusted R replaceAll(R, C, RegEx)(R input, RegEx re, const(C)[] format)
    if(isSomeString!R && is(C : dchar) && isRegexFor!(RegEx, R))
{
    return replaceAllWith!((m, sink) => replaceFmt(format, m, sink))(input, re);
}

/++
    This is a general replacement tool that construct a new string by replacing
    matches of pattern $(D re) in the $(D input). Unlike the other overload
    there is no format string instead captures are passed to
    to a user-defined functor $(D fun) that returns a new string
    to use as replacement.

    This version replaces all of the matches found in $(D input),
    see $(LREF replaceFirst) to replace the first match only.

    Returns:
    A new string of the same type as $(D input) with all matches
    replaced by return values of $(D fun). If no matches found
    returns the $(D input) itself.

    Params:
    input = string to search
    re = compiled regular expression
    fun = delegate to use

    Example:
    Capitalize the letters 'a' and 'r':
    ---
    string baz(Captures!(string) m)
    {
        return std.string.toUpper(m.hit);
    }
    auto s = replaceAll!(baz)("Strap a rocket engine on a chicken.",
            regex("[ar]"));
    assert(s == "StRAp A Rocket engine on A chicken.");
    ---
+/
public @trusted R replaceAll(alias fun, R, RegEx)(R input, RegEx re)
    if(isSomeString!R && isRegexFor!(RegEx, R))
{
    return replaceAllWith!((m, sink) => sink.put(fun(m)))(input, re);
}

/++
    A variation on $(LREF replaceAll) that instead of allocating a new string
    on each call outputs the result piece-wise to the $(D sink). In particular
    this enables efficient construction of a final output incrementally.

    As with $(LREF replaceAll) there are 2 overloads - one with a format string,
    the other one with a user defined functor.

    Example:
    ---
    //swap all 3 letter words and bring it back
    string text = "How are you doing?";
    auto sink = appender!(char[])();
    replaceAllInto!(cap => retro(cap[0]))(sink, text, regex(`\b\w{3}\b`));
    auto swapped = sink.data.dup; // make a copy explicitly
    assert(swapped == "woH era uoy doing?");
    sink.clear();
    replaceAllInto!(cap => retro(cap[0]))(sink, swapped, regex(`\b\w{3}\b`));
    assert(sink.data == text);
    ---
+/
public @trusted void replaceAllInto(Sink, R, C, RegEx)
        (Sink sink, R input, RegEx re, const(C)[] format)
    if(isOutputRange!(Sink, dchar) && isSomeString!R
        && is(C : dchar) && isRegexFor!(RegEx, R))
    {
    replaceMatchesInto!((m, sink) => replaceFmt(format, m, sink))
        (sink, input, matchAll(input, re));
    }

///ditto
public @trusted void replaceAllInto(alias fun, Sink, R, RegEx)
        (Sink sink, R input, RegEx re)
    if(isOutputRange!(Sink, dchar) && isSomeString!R && isRegexFor!(RegEx, R))
{
    replaceMatchesInto!fun(sink, input, matchAll(input, re));
}

// a bit of examples
@system unittest
{
    //swap all 3 letter words and bring it back
    string text = "How are you doing?";
    auto sink = appender!(char[])();
    replaceAllInto!(cap => retro(cap[0]))(sink, text, regex(`\b\w{3}\b`));
    auto swapped = sink.data.dup; // make a copy explicitly
    assert(swapped == "woH era uoy doing?");
    sink.clear();
    replaceAllInto!(cap => retro(cap[0]))(sink, swapped, regex(`\b\w{3}\b`));
    assert(sink.data == text);
}

// exercise all of the replace APIs
@system unittest
{
    import std.conv;
    // try and check first/all simple substitution
    foreach(S; TypeTuple!(string, wstring, dstring, char[], wchar[], dchar[]))
    {
        S s1 = "curt trial".to!S();
        S s2 = "round dome".to!S();
        S t1F = "court trial".to!S();
        S t2F = "hound dome".to!S();
        S t1A = "court trial".to!S();
        S t2A = "hound home".to!S();
        auto re1 = regex("curt".to!S());
        auto re2 = regex("[dr]o".to!S());

        assert(replaceFirst(s1, re1, "court") == t1F);
        assert(replaceFirst(s2, re2, "ho") == t2F);
        assert(replaceAll(s1, re1, "court") == t1A);
        assert(replaceAll(s2, re2, "ho") == t2A);

        auto rep1 = replaceFirst!(cap => cap[0][0]~"o".to!S()~cap[0][1..$])(s1, re1);
        assert(rep1 == t1F);
        assert(replaceFirst!(cap => "ho".to!S())(s2, re2) == t2F);
        auto rep1A = replaceAll!(cap => cap[0][0]~"o".to!S()~cap[0][1..$])(s1, re1);
        assert(rep1A == t1A);
        assert(replaceAll!(cap => "ho".to!S())(s2, re2) == t2A);

        auto sink = appender!S();
        replaceFirstInto(sink, s1, re1, "court");
        assert(sink.data == t1F);
        replaceFirstInto(sink, s2, re2, "ho");
        assert(sink.data == t1F~t2F);
        replaceAllInto(sink, s1, re1, "court");
        assert(sink.data == t1F~t2F~t1A);
        replaceAllInto(sink, s2, re2, "ho");
        assert(sink.data == t1F~t2F~t1A~t2A);
    }
}

/++
    Old API for replacement, operation depends on flags of pattern $(D re).
    With "g" flag it performs the equivalent of $(LREF replaceAll) otherwise it
    works the same as $(LREF replaceFirst).

    The use of this function is $(RED discouraged), please use $(LREF replaceAll)
    or $(LREF replaceFirst) explicitly.
+/
public R replace(alias scheme = match, R, C, RegEx)(R input, RegEx re, const(C)[] format)
    if(isSomeString!R && isRegexFor!(RegEx, R))
{
    return replaceAllWith!((m, sink) => replaceFmt(format, m, sink), match)(input, re);
}

///ditto
public R replace(alias fun, R, RegEx)(R input, RegEx re)
    if(isSomeString!R && isRegexFor!(RegEx, R))
{
    return replaceAllWith!(fun, match)(input, re);
}

/++
Range that splits a string using a regular expression as a
separator.

Example:
----
auto s1 = ", abc, de,  fg, hi, ";
assert(equal(splitter(s1, regex(", *")),
    ["", "abc", "de", "fg", "hi", ""]));
----
+/
public struct Splitter(Range, alias RegEx = Regex)
    if(isSomeString!Range && isRegexFor!(RegEx, Range))
{
private:
    Range _input;
    size_t _offset;
    alias Rx = typeof(match(Range.init,RegEx.init));
    Rx _match;

    @trusted this(Range input, RegEx separator)
    {//@@@BUG@@@ generated opAssign of RegexMatch is not @trusted
        _input = input;
        separator.flags |= RegexOption.global;
        if (_input.empty)
        {
            //there is nothing to match at all, make _offset > 0
            _offset = 1;
        }
        else
        {
            _match = Rx(_input, separator);
        }
    }

public:
    auto ref opSlice()
    {
        return this.save;
    }

    ///Forward range primitives.
    @property Range front()
    {
        import std.algorithm : min;

        assert(!empty && _offset <= _match.pre.length
                && _match.pre.length <= _input.length);
        return _input[_offset .. min($, _match.pre.length)];
    }

    ///ditto
    @property bool empty()
    {
        return _offset > _input.length;
    }

    ///ditto
    void popFront()
    {
        assert(!empty);
        if (_match.empty)
        {
            //No more separators, work is done here
            _offset = _input.length + 1;
        }
        else
        {
            //skip past the separator
            _offset = _match.pre.length + _match.hit.length;
            _match.popFront();
        }
    }

    ///ditto
    @property auto save()
    {
        return this;
    }
}

/**
    A helper function, creates a $(D Splitter) on range $(D r) separated by regex $(D pat).
    Captured subexpressions have no effect on the resulting range.
*/
public Splitter!(Range, RegEx) splitter(Range, RegEx)(Range r, RegEx pat)
    if(is(BasicElementOf!Range : dchar) && isRegexFor!(RegEx, Range))
{
    return Splitter!(Range, RegEx)(r, pat);
}

///An eager version of $(D splitter) that creates an array with splitted slices of $(D input).
public @trusted String[] split(String, RegEx)(String input, RegEx rx)
    if(isSomeString!String  && isRegexFor!(RegEx, String))
{
    auto a = appender!(String[])();
    foreach(e; splitter(input, rx))
        a.put(e);
    return a.data;
}

///Exception object thrown in case of errors during regex compilation.
public alias RegexException = std.regex.internal.ir.RegexException;