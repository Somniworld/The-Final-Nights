import { Window } from '../layouts';
import { InputButtons } from "./common/InputButtons";
import { useBackend, useLocalState } from "../backend";
import { KEY_ESCAPE } from "tgui-core/keycodes";
import { Box, Section, Stack, TextArea, Button } from "tgui-core/components";

export const sanitizeMultiline = toSanitize => {
  return toSanitize.replace(/(\n|\r\n){3,}/, "\n\n");
};

export const removeAllSkiplines = toSanitize => {
  return toSanitize.replace(/[\r\n]+/, "");
};

export const TruthOfGaia = (props) => {
  return (
    <Window title={'Truth of Gaia'}>
      <Window.Content>
        <Box>You have been asked the following question : ''. Firstly, write the answer your character would say. </Box>
          <TextArea
            autoFocus
            autoSelect
            height={15}
            maxLength={500}
            onEscape={() => act("cancel")}
            placeholder="Respond here, 500 characters max"
      />
      <Box>Was your character's answer truthful, from an OOC point of view? BE HONEST.</Box>
        <Button>TRUTH</Button>
        <Button>LIE</Button>
      </Window.Content>
    </Window>
  );
};
