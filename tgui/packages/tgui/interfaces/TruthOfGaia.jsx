import { Window } from '../layouts';
import { InputButtons } from "./common/InputButtons";
import { useBackend, useLocalState } from "../backend";
import { KEY_ESCAPE } from "tgui-core/keycodes";
import { Box, Section, Stack, TextArea, Button } from "tgui-core/components";
import { sanitizeText } from '../sanitize';

export const TruthOfGaia = (props) => {
  const {act} = useBackend()
  const [message,setMessage] = useLocalState("")
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
            sanitizeText
            value = {message}
            onChange = {(e,value) => setMessage(value)}
      />
      <Box>Was your character's answer truthful, from an OOC point of view? BE HONEST.</Box>
        <Button color ="green">TRUTH</Button>
        <Button color ="red">LIE</Button>
      <Box>Send reply?</Box>
        <Button color ="blue" onClick={() => act("send_answer",{text:message})} >DONE</Button>
      </Window.Content>
    </Window>
  );
};
