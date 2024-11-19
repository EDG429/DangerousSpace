extends RichTextLabel

var log_messages: Array = []  # Array to store log messages

@export var MAX_LOG_ENTRIES: int = 10  # Maximum number of log messages to keep visible

func _ready() -> void:
	# Ensure the RichTextLabel is configured correctly
	configure_rich_text_label()

	# Clear any existing content
	clear()
	visible = true
	print("LogManager initialized.")
	
	# Add a test log message
	add_log_message("This is a test log message.")  

func configure_rich_text_label() -> void:
	# Set up the RichTextLabel properties programmatically
	self.bbcode_enabled = true  # Enable BBCode for formatting if needed
	self.fit_content = true     # Ensure the label adjusts its height to fit the content
	self.scroll_active = true   # Enable scrolling if the content exceeds the bounds
	self.scroll_following = true  # Auto-scroll to the bottom when new text is added
	self.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART  # Wrap text neatly within the label bounds
	self.visible_characters = -1  # Display all characters (default)

	# Debug to confirm configuration
	print("RichTextLabel configured programmatically.")

func add_log_message(message: String) -> void:
	# Debugging the current state of log_messages
	print("Adding log message:", message)
	
	# Add the new message to the log array
	log_messages.append(message)
	
	# Remove the oldest message if we exceed the max limit
	if log_messages.size() > MAX_LOG_ENTRIES:
		log_messages.pop_front()
	
	# Directly update the RichTextLabel
	update_log()

func update_log() -> void:
	print("updating log")
	# Clear the existing content of the label
	clear()
	
	# Append each message to the RichTextLabel
	for log_message in log_messages:
		print("Updating log with message:", log_message)  # Debugging the current log
		append_text(log_message + "\n")
