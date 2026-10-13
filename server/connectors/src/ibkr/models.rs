use serde_json::Value;

/// A parsed Flex Web Service response: either the `FlexStatementResponse` envelope
/// (request accepted / failed) or a generated `FlexQueryResponse` statement.
#[derive(Debug)]
pub(crate) enum FlexReply {
    Accepted { reference_code: String },
    Failed { code: Option<u32>, message: String },
    Statement(Vec<Value>),
}
