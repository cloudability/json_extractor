#include <ruby.h>

// Needed for isspace.
#include <ctype.h>

#define PARSER_FUNC(fn) unsigned int fn(char *, long, unsigned int)

PARSER_FUNC(object);
PARSER_FUNC(object_body);
PARSER_FUNC(array);
PARSER_FUNC(array_body);
PARSER_FUNC(start);
PARSER_FUNC(whitespace);

/**
 * Reads the entire file pointed to by filename in to memory and returns a
 * pointer. The caller is responsible for freeing the pointer.
 *
 * @param [const char*] filename the filename
 * @return [char *] a buffer with the file's context. Must be free'd by caller.
 */
char * read_all(const char * filename) {
  long pos, actual;
  char *data;
  FILE *fp;

  fp = fopen(filename, "rb");

  if(!fp) {
    return NULL;
  }

  fseek(fp, 0L, SEEK_END);
  pos = ftell(fp);
  rewind(fp);

  // Read the whole damn thing in to memory!
  data = malloc(pos);
  memset(data, '\0', pos);

  actual = fread(data, sizeof(char), pos, fp);

  if(actual != pos) {
    free(data);
    return NULL;
  }

  return data;
}

/**
 * Finds the end of the whitespace that is currently under pos within str.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the whitespace
 */
unsigned int whitespace(char * str, long len, unsigned int pos) {
  while(isspace(str[pos]) && pos < len) {
    pos++;
  }

  if(pos < len) {
    return pos;
  } else {
    return -1;
  }
}

/**
 * Finds the end of the current object body that is under pos within str.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the object body.
 */
unsigned int object_body(char * str, long len, unsigned int pos) {
  while(pos < len) {
    if(str[pos+1] == '{') {
      pos = object(str, len, pos+1);
    }

    if(str[pos+1] == '}') {
      return pos;
    }

    pos++;
  }

  // We ran out--it was unescaped.
  return(-1);
}

/**
 * Finds the end of the current object that is under pos within str.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the object.
 */
unsigned int object(char * str, long len, unsigned int pos) {
  if(str[pos] != '{') {
    // This is an error--we should tell someone, me thinks.
    return -1;
  }

  pos = object_body(str, len, pos+1);

  if(str[pos+1] == '}') {
    return pos+1;
  }

  // Something else went wrong.
  return(-1);
}

/**
 * Finds the end of the current array body that is under pos within str.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the array body.
 */
unsigned int array_body(char * str, long len, unsigned int pos) {
  while(pos < len) {
    if(str[pos+1] == '[') {
      pos = array(str, len, pos+1);
    }

    if(str[pos+1] == ']') {
      return pos;
    }

    pos++;
  }

  return -1;
}

/**
 * Finds the end of the current array that is under pos within str.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the array.
 */
unsigned int array(char * str, long len, unsigned int pos) {
  if(str[pos] != '[') {
    return -1;
  }

  pos = array_body(str, len, pos);

  if(str[pos+1] == ']') {
    return pos+1;
  }

  return -1;
}

/**
 * Starts parsing.
 *
 * @param [char *] str the string to search.
 * @param [long] len the overall length of the string.
 * @param [unsigned int] pos the initial position (i.e. where to start)
 * @return [unsigned int] the end of the first-encountered object.
 */
unsigned int start(char * str, long len, unsigned int pos) {
  pos = whitespace(str, len, pos);

  if(str[pos] == '{') {
    return object(str, len, pos);
  } else if(str[pos] == '[') {
    return array(str, len, pos);
  }

  return -1;
}

int find_subdocument(char * str, unsigned int pos) {
  if(str == NULL) {
    return -1;
  }

  if(pos >= strlen(str)) {
    return -1;
  }

  return start(str, strlen(str), pos);
}

char * extract_subdocument(char * data, const char * key) {
  char *full_key, *pos, *final;
  int end;

  full_key = malloc(strlen(key) + 4);
  memset(full_key, '\0', strlen(key) + 4);

  sprintf(full_key, "\"%s\":", key);
  pos = strstr(data, full_key);

  if(pos == NULL) {
    free(full_key);
    return NULL;
  }

  // Let's find the end of the document.
  end = find_subdocument(&pos[strlen(full_key)], 0);

  if(end < 0) {
    final = NULL;
  } else {
    // Since we get a position, it's actually off by one from the original
    // position.
    final = malloc(end+2);
    memset(final, '\0', end+2);
    memcpy(final, &pos[strlen(full_key)], end+1);
  }

  free(full_key);

  return final;
}

int file_exists(char * filename) {
  FILE * fp;

  if(fp = fopen(filename, "r")) {
    fclose(fp);
    return 1;
  }

  return 0;
}

static VALUE rb_extract_subdocument(VALUE self, VALUE str, VALUE key) {
  char *data, *substr;
  VALUE result;

  // No str?
  if(str == Qnil) {
    return Qnil;
  }

  // No key?
  if(key == Qnil) {
    return Qnil;
  }

  // If str points to a file, let's read it and use that. Otherwise...
  if(file_exists(RSTRING_PTR(str))) {
    data = read_all(RSTRING_PTR(str));
    substr = extract_subdocument(data, RSTRING_PTR(key));
    free(data);
  } else {
    substr = extract_subdocument(RSTRING_PTR(str), RSTRING_PTR(key));
  }

  if(substr == NULL) {
    return Qnil;
  }

  result = rb_str_new2(substr);

  // TODO: Figure out if this is right. It behaves properly, so I'm assuming
  // it's OK.
  free(substr);

  return result;
}

void Init_json_extractor(void) {
  VALUE rb_mJSONExtractor = rb_define_module("JSONExtractor");
  rb_define_singleton_method(rb_mJSONExtractor, "extract_subdocument", rb_extract_subdocument, 2);
}
