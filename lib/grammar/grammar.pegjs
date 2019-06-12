{ const { _ }	= options }
CommitMessage
	= title:Title Newline? message:Message? {
		if (!message) {
			return {
				prefix: title.prefix,
				subject: title.subject,
				fullTitle: title.fullTitle,
				body: '',
				footers: [],
				message: ''
			}
		}
		return {
			prefix: title.prefix,
			subject: title.subject,
			fullTitle: title.fullTitle,
			body: message.body,
			footers: message.footers,
			message: message.message
		};
	}

Title
	= prefix:Prefix? subject:Subject {
		let delimiter = ': '
		if (!prefix) {
			prefix = ''
			delimiter = ''
		}
		return {
			prefix: prefix,
			subject: subject,
			fullTitle: prefix + delimiter + subject
		};
	}

Newline "newline between title and body"
	= '\n' / '\r\n'

Message "body and footers"
	= body:Body? footers:Footers? {
		return {
			body,
			footers: footers || [],
			message: body + (body && footers ? '\n\n' : '') + (footers ? footers.join('\n') : '')
		}
	}

Prefix "prefix"
	= prefix:$[^: \n\t\r]+ extraSpaces:$_* Colon _ {
		if (extraSpaces) {
			prefix = prefix + extraSpaces
		}
		return prefix
	}

Colon ": between prefix and subject in commit title"
	= ':'

Subject "subject"
	= $(notEOL+)


Body "body"
	= body:$(
		!Footers
		(notEOL* Newline / notEOL+)
	)* {
		return _.trim(body.replace(/\r/g, ''), '\n')
	}

Footers "footers" =
	Newline f:Footer fs:(Newline x:Footer { return x })* Newline? {
		return [f].concat(fs)
	}

Footer "footer"
	= $([A-Za-z\-]+ ': ' notEOL+)

notEOL = [^\r\n]

_ "space"
	= ' '
