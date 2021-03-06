/*
 * Append Example
 *
 * This sketch shows how to use open for append and the Arduino Print class
 * with IDEFat.
 */
#include <IDEFat.h>
#include <IDEFatUtil.h> // use functions to print strings from flash memory

IDE ide;
IDEVolume volume;
IDEFile root;
IDEFile file;

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))

void error_P(const char* str) {
  PgmPrint("error: ");
  SerialPrintln_P(str);
  if (ide.errorCode()) {
    PgmPrint("IDE error: ");
    Serial.print(ide.errorCode(), HEX);
    Serial.print(',');
    Serial.println(ide.errorData(), HEX);
  }
  while(1);
}

void setup(void) {
  Serial.begin(9600);
  Serial.println();
  PgmPrintln("Type any character to start");
  while (!Serial.available());
  
  if (!ide.init()) error("ide.init failed");

  // initialize a FAT volume on partition 2
  if (!volume.init(&ide, 2)) error("volume.init failed");

  // open the root directory
  if (!root.openRoot(&volume)) error("openRoot failed");
  
  char name[] = "APPEND.TXT";
  PgmPrint("Appending to: ");
  Serial.println(name);
  
  // clear write error
  file.writeError = false;
  
  for (uint8_t i = 0; i < 100; i++) {
    // O_CREAT - create the file if it does not exist
    // O_APPEND - seek to the end of the file prior to each write
    // O_WRITE - open for write
    if (!file.open(&root, name, O_CREAT | O_APPEND | O_WRITE)) {
      error("open failed");
    }
    // print 100 lines to file
    for (uint8_t j = 0; j < 100; j++) {
      file.print("line ");
      file.print(j, DEC);
      file.print(" of pass ");
      file.print(i, DEC);
      file.print(" millis = ");
      file.println(millis());
    }
    if (file.writeError) error("write failed");
    if (!file.close()) error("close failed");
    if (i > 0 && i%25 == 0)Serial.println();
    Serial.print('.');
  }
  Serial.println();
  Serial.println("Done");
}
void loop(void){}
