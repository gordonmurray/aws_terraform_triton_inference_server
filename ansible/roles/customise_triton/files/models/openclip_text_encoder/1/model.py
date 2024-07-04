import torch
import open_clip

import triton_python_backend_utils as pb_utils


class TritonPythonModel:
    def __init__(self):
        self.logger = None
        self.tokenizer = None
        self.preprocess = None
        self.model = None

        self.model_name = 'ViT-L-14'
        self.model_path = '/model_cache/laion--CLIP-ViT-L-14-laion2B-s32B-b82K/model.bin'

    def initialize(self, args):
        self.logger = pb_utils.Logger

        self.logger.log_info(f'Loading model name={self.model_name}, path={self.model_path}')

        model, _, preprocess = open_clip.create_model_and_transforms(
            model_name=self.model_name,
            pretrained=self.model_path,
            jit=False,
            device='cpu',  # 'cpu' or 'cuda'
        )
        tokenizer = open_clip.get_tokenizer('ViT-L-14')
        self.model = model
        self.preprocess = preprocess
        self.tokenizer = tokenizer

    def execute(self, requests):
        responses = []

        for request in requests:
            input_tokens = pb_utils.get_input_tensor_by_name(request, 'text_encoder_input').as_numpy()
            input_tensors = torch.tensor(input_tokens).to('cpu')

            self.logger.log_info(f'Encoding tensors={input_tensors}')

            with torch.no_grad():
                output_embeddings = self.model.encode_text(input_tensors, normalize=True).cpu().numpy()

            inference_response = pb_utils.InferenceResponse(
                output_tensors=[pb_utils.Tensor('text_encoder_output', output_embeddings)]
            )
            responses.append(inference_response)

        return responses

    def finalize(self):
        pass
