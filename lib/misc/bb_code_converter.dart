/// quick&dirty port from https://github.com/tcort/tcbbcode :D
class BBCodeConverter {
  String output = '';
  var openTags = [];
  var captureUrl = false;
  var url = '';
  var params = [];

  var allowedColors = [
    'aqua',
    'black',
    'blue',
    'fuchsia',
    'gray',
    'green',
    'lime',
    'maroon',
    'navy',
    'olive',
    'purple',
    'red',
    'silver',
    'teal',
    'white',
    'yellow',
  ];

  var inlineTags = [
    'b',
    'i',
    'u',
    's',
    'del',
    'ins',
    'em',
    'color',
    'bgcolor',
    'url',
    'style',
    'size',
    'img',
    'spoiler',
    'sub',
    'sup',
    'note',
  ];

  var blockTags = [
    'center',
    'right',
    'left',
    'justify',
    'quote',
    'pre',
    'code',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'table',
    'tr',
    'th',
    'td',
    'list',
    'ol',
    'ul',
    'li',
    'youtube',
  ];

  var standaloneTags = ['nbsp', 'hr', 'rand'];

  tagAllowedInContext(tag) {
    expectParent(tag) => (openTags.isNotEmpty && openTags[openTags.length - 1] == tag);

    // block tags cannot be inside inline tags
    if (blockTags.contains(tag) && (openTags.isNotEmpty && inlineTags.contains(openTags[openTags.length - 1]))) {
      return false;
    }

    switch (tag) {
      case 'tr': // <tr> must be a child of <table>
        return expectParent('table');
      case 'td': // <td> must be a child of <tr>
        return expectParent('tr');
      case 'th': // <th> must be a child of <tr>
        return expectParent('tr');
      case 'li': // <li> must be child of <ul> or <ol>
        return expectParent('ul') || expectParent('ol') || expectParent('list');
      default:
        return true;
    }
  }

  standaloneTag(tag) {
    if (match(r"^\[hr\]$", tag)) {
      output += '<hr/>';
    } else if (match(r"^\[nbsp\]$", tag)) {
      output += '&nbsp;';
    }
  }

  startTag(String tag) {
    String colorOrHex;
    String url;

    if (match(r"^\[b\]$", tag)) {
      output += '<b>';
    } else if (match(r"^\[i\]$", tag)) {
      output += '<i>';
    } else if (match(r"^\[u\]$", tag)) {
      output += '<u>';
    } else if (match(r"^\[s\]$", tag)) {
      output += '<s>';
    } else if (match(r"^\[del\]$", tag)) {
      output += '<del>';
    } else if (match(r"^\[ins\]$", tag)) {
      output += '<ins>';
    } else if (match(r"^\[em\]$", tag)) {
      output += '<em>';
    } else if (match(r"^\[sub\]$", tag)) {
      output += '<sub>';
    } else if (match(r"^\[sup\]$", tag)) {
      output += '<sup>';
    } else if (match(r"""^\[size="?[0-9]+\"?]$""", tag)) {
      var substring = withoutQuotes(tag.substring(6, tag.length - 1));
      output += """<span style="font-size: ${substring}pt;">""";
    } else if (match(r"^\[style size=[0-9]+\]$", tag)) {
      output += """<span style="font-size: ${tag.substring(12, tag.length - 1)}pt;">""";
    } else if (match(r"""^\[color="?([A-Za-z]+|#[0-9a-fA-F]{6})"?]$""", tag)) {
      colorOrHex = withoutQuotes(tag.substring(7, tag.length - 1).toLowerCase());
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    } else if (match(r"^\[bgcolor=([A-Za-z]+|#[0-9a-f]{6})\]$", tag)) {
      colorOrHex = tag.substring(9, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="background: $colorOrHex;">""";
    } else if (match(r"^\[style color=([A-Za-z]+|#[0-9a-f]{6})\]$", tag)) {
      colorOrHex = tag.substring(13, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    } else if (match(r"^\[center\]$", tag)) {
      output += '<div style="text-align: center;">';
    } else if (match(r"^\[left\]$", tag)) {
      output += '<div style="text-align: left;">';
    } else if (match(r"^\[right\]$", tag)) {
      output += '<div style="text-align: right;">';
    } else if (match(r"^\[justify\]$", tag)) {
      output += '<div style="text-align: justify;">';
    } else if (match(r"^\[quote.*?\]$", tag)) {
      output += '<div style="background-color: lightgray;">';
    } else if (match(r"^\[pre\]$", tag)) {
      output += '<pre>';
    } else if (match(r"^\[code\]$", tag)) {
      output += '<div><pre><code>';
    } else if (match(r"^\[code=[A-Za-z]+\]$", tag)) {
      output += """<div class="bbcode-code-lang-${tag.substring(6, tag.length - 1).toLowerCase()}"><pre><code>""";
    } else if (match(r"^\[h1\]$", tag)) {
      output += '<h1>';
    } else if (match(r"^\[h2\]$", tag)) {
      output += '<h2>';
    } else if (match(r"^\[h3\]$", tag)) {
      output += '<h3>';
    } else if (match(r"^\[h4\]$", tag)) {
      output += '<h4>';
    } else if (match(r"^\[h5\]$", tag)) {
      output += '<h5>';
    } else if (match(r"^\[h6\]$", tag)) {
      output += '<h6>';
    } else if (match(r"^\[table\]$", tag)) {
      output += '<table>';
    } else if (match(r"^\[tr\]$", tag)) {
      output += '<tr>';
    } else if (match(r"^\[td\]$", tag)) {
      output += '<td>';
    } else if (match(r"^\[th\]$", tag)) {
      output += '<th>';
    } else if (match(r"^\[list\]$", tag)) {
      output += '<ul>';
    } else if (match(r"^\[ul\]$", tag)) {
      output += '<ul>';
    } else if (match(r"^\[ol\]$", tag)) {
      output += '<ol>';
    } else if (match(r"^\[li\]$", tag)) {
      output += '<li>';
    } else if (match(r"^\[note\]$", tag)) {
      output += '<!-- ';
    } else if (match(r"^\[hide\]$", tag)) {
      //output += '<details><summary>Hidden</summary><p>';
      output += 'HIDE';
    } else if (match(r"^\[img\]$", tag)) {
      this.url = '';
      captureUrl = true;
      params = [];
    } else if (match(r"^\[img=[1-9][0-9]*x[1-9][0-9]*\]$", tag)) {
      this.url = '';
      captureUrl = true;
      params = tag.substring(5, tag.length - 1).toLowerCase().split('x');
    } else if (match(r"^\[img width=[1-9][0-9]* height=[1-9][0-9]*\]$", tag)) {
      this.url = '';
      captureUrl = true;
      params = tag.substring(5, tag.length - 1).split(' ').map((kv) => kv.split('=')[1]).toList();
    } else if (match(r"^\[youtube\]$", tag)) {
      this.url = '';
      captureUrl = true;
    } else if (match(r"^\[url\]$", tag)) {
      this.url = '';
      captureUrl = true;
    } else if (match(r"^\[url=[^\]]+\]$", tag)) {
      try {
        url = Uri.parse(withoutQuotes(tag.substring(5, tag.length - 1))).toString();
        if (match(r"^javascript", url)) {
          throw Exception('BBCode.startTag(tag): javascript scheme not allowed');
        }
        // normalize and validate URL
        output += """<a href="$url">""";
      } catch (err) {
        throw Exception('BBCode.startTag(tag): Invalid URL');
      }
    } else {
        print('BBCode.startTag(tag): unrecognized BBCode: $tag');
    }

    var actualTag = tag.substring(1).split(RegExp(r"[ =\]]"))[0];
    if (!tagAllowedInContext(actualTag)) {
      throw Exception('BBCode.startTag(tag): tag not allowed in this context');
    }
    openTags.insert(0, actualTag);
  }

  text(txt) {
    if (txt is! String) {
      throw Exception('BBCode.text(txt): txt must be a string.');
    }

    if (captureUrl) {
      url = txt;
    } else {
      output += txt;
    }
  }

  endTag(tag) {
    if (tag is! String) {
      throw Exception('BBCode.endTag(tag): tag must be a string.');
    }

    if (match(r"^\[\/b\]$", tag)) {
      output += '</b>';
    } else if (match(r"^\[\/i\]$", tag)) {
      output += '</i>';
    } else if (match(r"^\[\/u\]$", tag)) {
      output += '</u>';
    } else if (match(r"^\[\/s\]$", tag)) {
      output += '</s>';
    } else if (match(r"^\[\/del\]$", tag)) {
      output += '</del>';
    } else if (match(r"^\[\/ins\]$", tag)) {
      output += '</ins>';
    } else if (match(r"^\[\/em\]$", tag)) {
      output += '</em>';
    } else if (match(r"^\[\/sub\]$", tag)) {
      output += '</sub>';
    } else if (match(r"^\[\/sup\]$", tag)) {
      output += '</sup>';
    } else if (match(r"^\[\/size\]$", tag)) {
      output += '</span>';
    } else if (match(r"^\[\/style\]$", tag)) {
      output += '</span>';
    } else if (match(r"^\[\/color\]$", tag)) {
      output += '</span>';
    } else if (match(r"^\[\/bgcolor\]$", tag)) {
      output += '</span>';
    } else if (match(r"^\[\/center\]$", tag)) {
      output += '</div>';
    } else if (match(r"^\[\/left\]$", tag)) {
      output += '</div>';
    } else if (match(r"^\[\/right\]$", tag)) {
      output += '</div>';
    } else if (match(r"^\[\/justify\]$", tag)) {
      output += '</div>';
    } else if (match(r"^\[\/quote\]$", tag)) {
      output += '</div>';
    } else if (match(r"^\[\/pre\]$", tag)) {
      output += '</pre>';
    } else if (match(r"^\[\/code\]$", tag)) {
      output += '</code></pre></div>';
    } else if (match(r"^\[\/h1\]$", tag)) {
      output += '</h1>';
    } else if (match(r"^\[\/h2\]$", tag)) {
      output += '</h2>';
    } else if (match(r"^\[\/h3\]$", tag)) {
      output += '</h3>';
    } else if (match(r"^\[\/h4\]$", tag)) {
      output += '</h4>';
    } else if (match(r"^\[\/h5\]$", tag)) {
      output += '</h5>';
    } else if (match(r"^\[\/h6\]$", tag)) {
      output += '</h6>';
    } else if (match(r"^\[\/table\]$", tag)) {
      output += '</table>';
    } else if (match(r"^\[\/tr\]$", tag)) {
      output += '</tr>';
    } else if (match(r"^\[\/td\]$", tag)) {
      output += '</td>';
    } else if (match(r"^\[\/th\]$", tag)) {
      output += '</th>';
    } else if (match(r"^\[\/list\]$", tag)) {
      output += '</ul>';
    } else if (match(r"^\[\/ul\]$", tag)) {
      output += '</ul>';
    } else if (match(r"^\[\/ol\]$", tag)) {
      output += '</ol>';
    } else if (match(r"^\[\/li\]$", tag)) {
      output += '</li>';
    } else if (match(r"^\[\/note\]$", tag)) {
      output += ' -->';
    } else if (match(r"^\[\/Hide]$", tag)) {
      //output += '</p></details>';
      output += '/HIDE';
    } else if (match(r"^\[\/img\]$", tag)) {
      //var params = this.params.length == 2 ? """width="${this.params[0]}" height="${this.params[1]}" """ : '';
      this.params = [];
      if (captureUrl) {
        captureUrl = false;
        try {
          // normalize and validate URL
          output += "!!Image!!: $url";
          //output +=
          //    """<img src="${Uri.parse(url).toString()}" alt="${basename(Uri.parse(url).path)}" $params/>""";
        } catch (err) {
          throw Exception('Invalid URL');
        }
      } else {
        throw Exception('BBCode.endTag(tag): internal error');
      }
    } else if (match(r"^\[\/youtube\]$", tag)) {
      if (captureUrl) {
        captureUrl = false;
        if (match(r"/^[A-Za-z0-9_\-]{11}$/", url)) {
          output +=
              """<div><iframe width="560" height="315" src="https://www.youtube.com/embed/$url" title="YouTube video player" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>""";
        } else {
          throw Exception('BBCode.endTag(tag): bad youtube_id');
        }
      } else {
        throw Exception('BBCode.endTag(tag): internal error');
      }
    } else if (match(r"^\[\/url\]$", tag)) {
      if (captureUrl) {
        captureUrl = false;
        try {
          // normalize and validate URL
          output += """<a href="${Uri.parse(url).toString()}">""";
          output += url;
        } catch (err) {
          throw Exception('Invalid URL');
        }
      }
      output += '</a>';
    } else {
      throw Exception('BBCode.endTag(tag): unrecognized BBCode');
    }

    String expectedTag = openTags.removeAt(0);
    String actualTag = tag.substring(2).split(RegExp(r"[ =\]]"))[0];
    if (expectedTag.toLowerCase() != actualTag.toLowerCase()) {
      print('BBCode.endTag(tag): unbalanced tags: $expectedTag != $actualTag');
    }
  }

  bool match(String regex, String match) => RegExp(regex, caseSensitive: false).hasMatch(match);

  done() {
    if (openTags.isNotEmpty) {
      print('BBCode.done(): missing closing tag(s)');
    }
    var output = this.output;
    this.output = '';
    return output;
  }

  parse(String inputString) {
    output = '';
    openTags = [];

    List<String> input = encodeHtmlEntities(inputString).split('');

    var token = '';
    var inTag = false;

    while (input.isNotEmpty) {
      var ch = input.removeAt(0);

      if (inTag && ch == ']') {
        token += ch;
        inTag = false;
        if (token[1] == '/') {
          endTag(token);
        } else if (standaloneTags.contains(token.substring(1, token.length - 1))) {
          standaloneTag(token);
        } else {
          startTag(token);
        }
        token = '';
      } else if (!inTag && ch == '[') {
        input.insert(0, ch);
        inTag = true;
        if (token.isNotEmpty) {
          text(token);
        }
        token = '';
      } else {
        token += ch;
      }
    }

    output += token; // append any trailing text

    return done();
  }

  static String encodeHtmlEntities(input) {
    if (input is! String) {
      throw Exception('BBCode.encodeEntities(input): input must be a string.');
    }
    return input.replaceAllMapped("""/[\u00A0-\u9999<>&"']/gim""", (ch) => """&#${ch.input[0]};""");
  }

  static basename(path) {
    return """$path""".split('/').first;
  }

  withoutQuotes(String text) {
    if (text.startsWith("\"")) return text.substring(1, text.length - 1);
    return text;
  }
}
