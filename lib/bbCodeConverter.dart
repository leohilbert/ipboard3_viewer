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

  var standaloneTags = ['nbsp', 'hr'];

  tagAllowedInContext(tag) {
    expectParent(tag) =>
        (openTags.isNotEmpty && openTags[openTags.length - 1] == tag);

    // block tags cannot be inside inline tags
    if (blockTags.contains(tag) &&
        (openTags.isNotEmpty &&
            inlineTags.contains(openTags[openTags.length - 1]))) {
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
    if (RegExp("/^\\[hr\\]\$/i").hasMatch(tag)) {
      output += '<hr/>';
    } else if (RegExp("/^\\[nbsp\\]\$/i").hasMatch(tag)) {
      output += '&nbsp;';
    }
  }

  startTag(String tag) {
    String colorOrHex;
    String url;

    if (RegExp("/^\\[b\\]\$/i").hasMatch(tag)) {
      output += '<b>';
    }

    if (RegExp("/^\\[i\\]\$/i").hasMatch(tag)) {
      output += '<i>';
    }

    if (RegExp("/^\\[u\\]\$/i").hasMatch(tag)) {
      output += '<u>';
    }

    if (RegExp("/^\\[s\\]\$/i").hasMatch(tag)) {
      output += '<s>';
    }

    if (RegExp("/^\\[del\\]\$/i").hasMatch(tag)) {
      output += '<del>';
    }

    if (RegExp("/^\\[ins\\]\$/i").hasMatch(tag)) {
      output += '<ins>';
    }

    if (RegExp("/^\\[em\\]\$/i").hasMatch(tag)) {
      output += '<em>';
    }

    if (RegExp("/^\\[sub\\]\$/i").hasMatch(tag)) {
      output += '<sub>';
    }

    if (RegExp("/^\\[sup\\]\$/i").hasMatch(tag)) {
      output += '<sup>';
    }

    if (RegExp("/^\\[size=[0-9]+\\]\$/i").hasMatch(tag)) {
      output +=
          """<span style="font-size: ${tag.substring(6, tag.length - 1)}pt;">""";
    }

    if (RegExp("/^\\[style size=[0-9]+\\]\$/i").hasMatch(tag)) {
      output +=
          """<span style="font-size: ${tag.substring(12, tag.length - 1)}pt;">""";
    }

    if (RegExp("/^\\[color=([A-Za-z]+|#[0-9a-f]{6})\\]\$/i").hasMatch(tag)) {
      colorOrHex = tag.substring(7, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    }

    if (RegExp("/^\\[bgcolor=([A-Za-z]+|#[0-9a-f]{6})\\]\$/i").hasMatch(tag)) {
      colorOrHex = tag.substring(9, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="background: $colorOrHex;">""";
    }

    if (RegExp("/^\\[style color=([A-Za-z]+|#[0-9a-f]{6})\\]\$/i")
        .hasMatch(tag)) {
      colorOrHex = tag.substring(13, tag.length - 1).toLowerCase();
      if (!colorOrHex.startsWith('#') && !allowedColors.contains(colorOrHex)) {
        throw Exception('BBCode.startTag(tag): invalid color or hex code');
      }
      output += """<span style="color: $colorOrHex;">""";
    }

    if (RegExp("/^\\[center\\]\$/i").hasMatch(tag)) {
      output += '<div style="text-align: center;">';
    }

    if (RegExp("/^\\[left\\]\$/i").hasMatch(tag)) {
      output += '<div style="text-align: left;">';
    }

    if (RegExp("/^\\[right\\]\$/i").hasMatch(tag)) {
      output += '<div style="text-align: right;">';
    }

    if (RegExp("/^\\[justify\\]\$/i").hasMatch(tag)) {
      output += '<div style="text-align: justify;">';
    }

    if (RegExp("/^\\[quote\\]\$/i").hasMatch(tag)) {
      output += '<blockquote>';
    }

    if (RegExp("/^\\[pre\\]\$/i").hasMatch(tag)) {
      output += '<pre>';
    }

    if (RegExp("/^\\[code\\]\$/i").hasMatch(tag)) {
      output += '<div><pre><code>';
    }

    if (RegExp("/^\\[code=[A-Za-z]+\\]\$/i").hasMatch(tag)) {
      output +=
          """<div class="bbcode-code-lang-${tag.substring(6, tag.length - 1).toLowerCase()}"><pre><code>""";
    }

    if (RegExp("/^\\[h1\\]\$/i").hasMatch(tag)) {
      output += '<h1>';
    }

    if (RegExp("/^\\[h2\\]\$/i").hasMatch(tag)) {
      output += '<h2>';
    }

    if (RegExp("/^\\[h3\\]\$/i").hasMatch(tag)) {
      output += '<h3>';
    }

    if (RegExp("/^\\[h4\\]\$/i").hasMatch(tag)) {
      output += '<h4>';
    }

    if (RegExp("/^\\[h5\\]\$/i").hasMatch(tag)) {
      output += '<h5>';
    }

    if (RegExp("/^\\[h6\\]\$/i").hasMatch(tag)) {
      output += '<h6>';
    }

    if (RegExp("/^\\[table\\]\$/i").hasMatch(tag)) {
      output += '<table>';
    }

    if (RegExp("/^\\[tr\\]\$/i").hasMatch(tag)) {
      output += '<tr>';
    }

    if (RegExp("/^\\[td\\]\$/i").hasMatch(tag)) {
      output += '<td>';
    }

    if (RegExp("/^\\[th\\]\$/i").hasMatch(tag)) {
      output += '<th>';
    }

    if (RegExp("/^\\[list\\]\$/i").hasMatch(tag)) {
      output += '<ul>';
    }

    if (RegExp("/^\\[ul\\]\$/i").hasMatch(tag)) {
      output += '<ul>';
    }

    if (RegExp("/^\\[ol\\]\$/i").hasMatch(tag)) {
      output += '<ol>';
    }

    if (RegExp("/^\\[li\\]\$/i").hasMatch(tag)) {
      output += '<li>';
    }

    if (RegExp("/^\\[note\\]\$/i").hasMatch(tag)) {
      output += '<!-- ';
    }

    if (RegExp("/^\\[img\\]\$/i").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = [];
    }

    if (RegExp("/^\\[img=[1-9][0-9]*x[1-9][0-9]*\\]\$/i").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = tag.substring(5, tag.length - 1).toLowerCase().split('x');
    }

    if (RegExp("/^\\[img width=[1-9][0-9]* height=[1-9][0-9]*\\]\$/i")
        .hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
      params = tag
          .substring(5, tag.length - 1)
          .split(' ')
          .map((kv) => kv.split('=')[1]).toList();
    }

    if (RegExp("/^\\[youtube\\]\$/i").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
    }

    if (RegExp("/^\\[url\\]\$/i").hasMatch(tag)) {
      this.url = '';
      captureUrl = true;
    }

    if (RegExp("/^\\[url=[^\\]]+\\]\$/i").hasMatch(tag)) {
      try {
        url = Uri.parse(tag.substring(5, tag.length - 1)).toString();
        if (RegExp("/^javascript/i").hasMatch(url)) {
          throw Exception(
              'BBCode.startTag(tag): javascript scheme not allowed');
        }
        // normalize and validate URL
        output += """<a href="$url">""";
      } catch (err) {
        throw Exception('BBCode.startTag(tag): Invalid URL');
      }
    } else {
      throw Exception('BBCode.startTag(tag): unrecognized BBCode');
    }

    var actualTag = tag.substring(1).split("/[ =\\]]/")[0];
    if (!tagAllowedInContext(actualTag)) {
      throw Exception('BBCode.startTag(tag): tag not allowed in this context');
    }
    openTags.add(actualTag);
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

    if (RegExp("/^\\[\\/b\\]\$/i").hasMatch(tag)) {
      output += '</b>';
    }

    if (RegExp("/^\\[\\/i\\]\$/i").hasMatch(tag)) {
      output += '</i>';
    }

    if (RegExp("/^\\[\\/u\\]\$/i").hasMatch(tag)) {
      output += '</u>';
    }

    if (RegExp("/^\\[\\/s\\]\$/i").hasMatch(tag)) {
      output += '</s>';
    }

    if (RegExp("/^\\[\\/del\\]\$/i").hasMatch(tag)) {
      output += '</del>';
    }

    if (RegExp("/^\\[\\/ins\\]\$/i").hasMatch(tag)) {
      output += '</ins>';
    }

    if (RegExp("/^\\[\\/em\\]\$/i").hasMatch(tag)) {
      output += '</em>';
    }

    if (RegExp("/^\\[\\/sub\\]\$/i").hasMatch(tag)) {
      output += '</sub>';
    }

    if (RegExp("/^\\[\\/sup\\]\$/i").hasMatch(tag)) {
      output += '</sup>';
    }

    if (RegExp("/^\\[\\/size\\]\$/i").hasMatch(tag)) {
      output += '</span>';
    }

    if (RegExp("/^\\[\\/style\\]\$/i").hasMatch(tag)) {
      output += '</span>';
    }

    if (RegExp("/^\\[\\/color\\]\$/i").hasMatch(tag)) {
      output += '</span>';
    }

    if (RegExp("/^\\[\\/bgcolor\\]\$/i").hasMatch(tag)) {
      output += '</span>';
    }

    if (RegExp("/^\\[\\/center\\]\$/i").hasMatch(tag)) {
      output += '</div>';
    }

    if (RegExp("/^\\[\\/left\\]\$/i").hasMatch(tag)) {
      output += '</div>';
    }

    if (RegExp("/^\\[\\/right\\]\$/i").hasMatch(tag)) {
      output += '</div>';
    }

    if (RegExp("/^\\[\\/justify\\]\$/i").hasMatch(tag)) {
      output += '</div>';
    }

    if (RegExp("/^\\[\\/quote\\]\$/i").hasMatch(tag)) {
      output += '</blockquote>';
    }

    if (RegExp("/^\\[\\/pre\\]\$/i").hasMatch(tag)) {
      output += '</pre>';
    }

    if (RegExp("/^\\[\\/code\\]\$/i").hasMatch(tag)) {
      output += '</code></pre></div>';
    }

    if (RegExp("/^\\[\\/h1\\]\$/i").hasMatch(tag)) {
      output += '</h1>';
    }

    if (RegExp("/^\\[\\/h2\\]\$/i").hasMatch(tag)) {
      output += '</h2>';
    }

    if (RegExp("/^\\[\\/h3\\]\$/i").hasMatch(tag)) {
      output += '</h3>';
    }

    if (RegExp("/^\\[\\/h4\\]\$/i").hasMatch(tag)) {
      output += '</h4>';
    }

    if (RegExp("/^\\[\\/h5\\]\$/i").hasMatch(tag)) {
      output += '</h5>';
    }

    if (RegExp("/^\\[\\/h6\\]\$/i").hasMatch(tag)) {
      output += '</h6>';
    }

    if (RegExp("/^\\[\\/table\\]\$/i").hasMatch(tag)) {
      output += '</table>';
    }

    if (RegExp("/^\\[\\/tr\\]\$/i").hasMatch(tag)) {
      output += '</tr>';
    }

    if (RegExp("/^\\[\\/td\\]\$/i").hasMatch(tag)) {
      output += '</td>';
    }

    if (RegExp("/^\\[\\/th\\]\$/i").hasMatch(tag)) {
      output += '</th>';
    }

    if (RegExp("/^\\[\\/list\\]\$/i").hasMatch(tag)) {
      output += '</ul>';
    }

    if (RegExp("/^\\[\\/ul\\]\$/i").hasMatch(tag)) {
      output += '</ul>';
    }

    if (RegExp("/^\\[\\/ol\\]\$/i").hasMatch(tag)) {
      output += '</ol>';
    }

    if (RegExp("/^\\[\\/li\\]\$/i").hasMatch(tag)) {
      output += '</li>';
    }

    if (RegExp("/^\\[\\/note\\]\$/i").hasMatch(tag)) {
      output += ' -->';
    }

    if (RegExp("/^\\[\\/img\\]\$/i").hasMatch(tag)) {
      var params = this.params.length == 2
          ? """width="${this.params[0]}" height="${this.params[1]}" """
          : '';
      this.params = [];
      if (captureUrl) {
        captureUrl = false;
        try {
          // normalize and validate URL
          output +=
              """<img src="${Uri.parse(url).toString()}" alt="${basename(Uri.parse(url).path)}" $params/>""";
        } catch (err) {
          throw Exception('Invalid URL');
        }
      } else {
        throw Exception('BBCode.endTag(tag): internal error');
      }
    }

    if (RegExp("/^\\[\\/youtube\\]\$/i").hasMatch(tag)) {
      if (captureUrl) {
        captureUrl = false;
        if (RegExp("/^[A-Za-z0-9_\\-]{11}\$/").hasMatch(url)) {
          output +=
              """<div><iframe width="560" height="315" src="https://www.youtube.com/embed/$url" title="YouTube video player" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>""";
        } else {
          throw Exception('BBCode.endTag(tag): bad youtube_id');
        }
      } else {
        throw Exception('BBCode.endTag(tag): internal error');
      }
    }

    if (RegExp("/^\\[\\/url\\]\$/i").hasMatch(tag)) {
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

    var expectedTag = openTags.first();
    var actualTag = tag.substring(2).split("/[ =\\]]/")[0];
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
        } else if (standaloneTags
            .contains(token.substring(1, token.length - 1))) {
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
    return input.replaceAllMapped(
        """/[\u00A0-\u9999<>\\&"']/gim""", (ch) => """&#${ch.input[0]};""");
  }

  static basename(path) {
    return """$path""".split('/').first;
  }

  tcbbcode(input) {
    return BBCodeConverter().parse(input);
  }
}
