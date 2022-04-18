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
    if (RegExp(r"^\[hr\]$").hasMatch(tag)) {
      output += '<hr/>';
    } else if (RegExp(r"^\[nbsp\]$").hasMatch(tag)) {
      output += '&nbsp;';
    }
  }

  startTag(String tag) {
    String colorOrHex;
    String url;

    if (RegExp(r"^\[b\]$").hasMatch(tag)) {
      output += '<b>';
    } else if (RegExp(r"^\[i\]$").hasMatch(tag)) {
      output += '<i>';
    } else if (RegExp(r"^\[u\]$").hasMatch(tag)) {
      output += '<u>';
    } else if (RegExp(r"^\[s\]$").hasMatch(tag)) {
      output += '<s>';
    } else if (RegExp(r"^\[del\]$").hasMatch(tag)) {
      output += '<del>';
    } else if (RegExp(r"^\[ins\]$").hasMatch(tag)) {
      output += '<ins>';
    } else if (RegExp(r"^\[em\]$").hasMatch(tag)) {
      output += '<em>';
    } else if (RegExp(r"^\[sub\]$").hasMatch(tag)) {
      output += '<sub>';
    } else if (RegExp(r"^\[sup\]$").hasMatch(tag)) {
      output += '<sup>';
    } else if (RegExp(r"""^\[size="?[0-9]+\"?]$""").hasMatch(tag)) {
      var substring = withoutQuotes(tag.substring(6, tag.length - 1));
      output += """<span style="font-size: ${substring}pt;">""";
    } else if (RegExp(r"^\[style size=[0-9]+\]$").hasMatch(tag)) {
      output += """<span style="font-size: ${tag.substring(12, tag.length - 1)}pt;">""";
    } else if (RegExp(r"""^\[color="?([A-Za-z]+|#[0-9a-fA-F]{6})"?]$""").hasMatch(tag)) {
      colorOrHex = withoutQuotes(tag.substring(7, tag.length - 1).toLowerCase());
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    } else if (RegExp(r"^\[bgcolor=([A-Za-z]+|#[0-9a-f]{6})\]$").hasMatch(tag)) {
      colorOrHex = tag.substring(9, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="background: $colorOrHex;">""";
    } else if (RegExp(r"^\[style color=([A-Za-z]+|#[0-9a-f]{6})\]$").hasMatch(tag)) {
      colorOrHex = tag.substring(13, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    } else if (RegExp(r"^\[center\]$").hasMatch(tag)) {
      output += '<div style="text-align: center;">';
    } else if (RegExp(r"^\[left\]$").hasMatch(tag)) {
      output += '<div style="text-align: left;">';
    } else if (RegExp(r"^\[right\]$").hasMatch(tag)) {
      output += '<div style="text-align: right;">';
    } else if (RegExp(r"^\[justify\]$").hasMatch(tag)) {
      output += '<div style="text-align: justify;">';
    } else if (RegExp(r"^\[quote.*?\]$").hasMatch(tag)) {
      output += '<blockquote>';
    } else if (RegExp(r"^\[pre\]$").hasMatch(tag)) {
      output += '<pre>';
    } else if (RegExp(r"^\[code\]$").hasMatch(tag)) {
      output += '<div><pre><code>';
    } else if (RegExp(r"^\[code=[A-Za-z]+\]$").hasMatch(tag)) {
      output += """<div class="bbcode-code-lang-${tag.substring(6, tag.length - 1).toLowerCase()}"><pre><code>""";
    } else if (RegExp(r"^\[h1\]$").hasMatch(tag)) {
      output += '<h1>';
    } else if (RegExp(r"^\[h2\]$").hasMatch(tag)) {
      output += '<h2>';
    } else if (RegExp(r"^\[h3\]$").hasMatch(tag)) {
      output += '<h3>';
    } else if (RegExp(r"^\[h4\]$").hasMatch(tag)) {
      output += '<h4>';
    } else if (RegExp(r"^\[h5\]$").hasMatch(tag)) {
      output += '<h5>';
    } else if (RegExp(r"^\[h6\]$").hasMatch(tag)) {
      output += '<h6>';
    } else if (RegExp(r"^\[table\]$").hasMatch(tag)) {
      output += '<table>';
    } else if (RegExp(r"^\[tr\]$").hasMatch(tag)) {
      output += '<tr>';
    } else if (RegExp(r"^\[td\]$").hasMatch(tag)) {
      output += '<td>';
    } else if (RegExp(r"^\[th\]$").hasMatch(tag)) {
      output += '<th>';
    } else if (RegExp(r"^\[list\]$").hasMatch(tag)) {
      output += '<ul>';
    } else if (RegExp(r"^\[ul\]$").hasMatch(tag)) {
      output += '<ul>';
    } else if (RegExp(r"^\[ol\]$").hasMatch(tag)) {
      output += '<ol>';
    } else if (RegExp(r"^\[li\]$").hasMatch(tag)) {
      output += '<li>';
    } else if (RegExp(r"^\[note\]$").hasMatch(tag)) {
      output += '<!-- ';
    } else if (RegExp(r"^\[img\]$").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = [];
    } else if (RegExp(r"^\[img=[1-9][0-9]*x[1-9][0-9]*\]$").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = tag.substring(5, tag.length - 1).toLowerCase().split('x');
    } else if (RegExp(r"^\[img width=[1-9][0-9]* height=[1-9][0-9]*\]$").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = tag.substring(5, tag.length - 1).split(' ').map((kv) => kv.split('=')[1]).toList();
    } else if (RegExp(r"^\[youtube\]$").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
    } else if (RegExp(r"^\[url\]$").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
    } else if (RegExp(r"^\[url=[^\]]+\]$").hasMatch(tag)) {
      try {
        url = Uri.parse(withoutQuotes(tag.substring(5, tag.length - 1))).toString();
        if (RegExp(r"^javascript").hasMatch(url)) {
          throw Exception('BBCode.startTag(tag): javascript scheme not allowed');
        }
        // normalize and validate URL
        output += """<a href="$url">""";
      } catch (err) {
        throw Exception('BBCode.startTag(tag): Invalid URL');
      }
    } else {
      if (!tag.contains("[rand")) {
        throw Exception('BBCode.startTag(tag): unrecognized BBCode');
      }
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

    if (RegExp(r"^\[\/b\]$").hasMatch(tag)) {
      output += '</b>';
    } else if (RegExp(r"^\[\/i\]$").hasMatch(tag)) {
      output += '</i>';
    } else if (RegExp(r"^\[\/u\]$").hasMatch(tag)) {
      output += '</u>';
    } else if (RegExp(r"^\[\/s\]$").hasMatch(tag)) {
      output += '</s>';
    } else if (RegExp(r"^\[\/del\]$").hasMatch(tag)) {
      output += '</del>';
    } else if (RegExp(r"^\[\/ins\]$").hasMatch(tag)) {
      output += '</ins>';
    } else if (RegExp(r"^\[\/em\]$").hasMatch(tag)) {
      output += '</em>';
    } else if (RegExp(r"^\[\/sub\]$").hasMatch(tag)) {
      output += '</sub>';
    } else if (RegExp(r"^\[\/sup\]$").hasMatch(tag)) {
      output += '</sup>';
    } else if (RegExp(r"^\[\/size\]$").hasMatch(tag)) {
      output += '</span>';
    } else if (RegExp(r"^\[\/style\]$").hasMatch(tag)) {
      output += '</span>';
    } else if (RegExp(r"^\[\/color\]$").hasMatch(tag)) {
      output += '</span>';
    } else if (RegExp(r"^\[\/bgcolor\]$").hasMatch(tag)) {
      output += '</span>';
    } else if (RegExp(r"^\[\/center\]$").hasMatch(tag)) {
      output += '</div>';
    } else if (RegExp(r"^\[\/left\]$").hasMatch(tag)) {
      output += '</div>';
    } else if (RegExp(r"^\[\/right\]$").hasMatch(tag)) {
      output += '</div>';
    } else if (RegExp(r"^\[\/justify\]$").hasMatch(tag)) {
      output += '</div>';
    } else if (RegExp(r"^\[\/quote\]$").hasMatch(tag)) {
      output += '</blockquote>';
    } else if (RegExp(r"^\[\/pre\]$").hasMatch(tag)) {
      output += '</pre>';
    } else if (RegExp(r"^\[\/code\]$").hasMatch(tag)) {
      output += '</code></pre></div>';
    } else if (RegExp(r"^\[\/h1\]$").hasMatch(tag)) {
      output += '</h1>';
    } else if (RegExp(r"^\[\/h2\]$").hasMatch(tag)) {
      output += '</h2>';
    } else if (RegExp(r"^\[\/h3\]$").hasMatch(tag)) {
      output += '</h3>';
    } else if (RegExp(r"^\[\/h4\]$").hasMatch(tag)) {
      output += '</h4>';
    } else if (RegExp(r"^\[\/h5\]$").hasMatch(tag)) {
      output += '</h5>';
    } else if (RegExp(r"^\[\/h6\]$").hasMatch(tag)) {
      output += '</h6>';
    } else if (RegExp(r"^\[\/table\]$").hasMatch(tag)) {
      output += '</table>';
    } else if (RegExp(r"^\[\/tr\]$").hasMatch(tag)) {
      output += '</tr>';
    } else if (RegExp(r"^\[\/td\]$").hasMatch(tag)) {
      output += '</td>';
    } else if (RegExp(r"^\[\/th\]$").hasMatch(tag)) {
      output += '</th>';
    } else if (RegExp(r"^\[\/list\]$").hasMatch(tag)) {
      output += '</ul>';
    } else if (RegExp(r"^\[\/ul\]$").hasMatch(tag)) {
      output += '</ul>';
    } else if (RegExp(r"^\[\/ol\]$").hasMatch(tag)) {
      output += '</ol>';
    } else if (RegExp(r"^\[\/li\]$").hasMatch(tag)) {
      output += '</li>';
    } else if (RegExp(r"^\[\/note\]$").hasMatch(tag)) {
      output += ' -->';
    } else if (RegExp(r"^\[\/img\]$").hasMatch(tag)) {
      var params = this.params.length == 2 ? """width="${this.params[0]}" height="${this.params[1]}" """ : '';
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
    } else if (RegExp(r"^\[\/youtube\]$").hasMatch(tag)) {
      if (captureUrl) {
        captureUrl = false;
        if (RegExp(r"/^[A-Za-z0-9_\-]{11}$/").hasMatch(url)) {
          output +=
              """<div><iframe width="560" height="315" src="https://www.youtube.com/embed/$url" title="YouTube video player" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>""";
        } else {
          throw Exception('BBCode.endTag(tag): bad youtube_id');
        }
      } else {
        throw Exception('BBCode.endTag(tag): internal error');
      }
    } else if (RegExp(r"^\[\/url\]$").hasMatch(tag)) {
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

    var expectedTag = openTags.removeAt(0);
    var actualTag = tag.substring(2).split(RegExp(r"[ =\]]"))[0];
    if (expectedTag != actualTag) {
      throw Exception('BBCode.endTag(tag): unbalanced tags');
    }
  }

  done() {
    if (openTags.isNotEmpty) {
      throw Exception('BBCode.done(): missing closing tag(s)');
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
