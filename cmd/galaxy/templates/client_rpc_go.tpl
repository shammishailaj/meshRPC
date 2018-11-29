// Code generated by galaxy. DO NOT EDIT.
// All changes must be done in custom client that should either embed or wrap this.

package {{.PackageName}}

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	log "github.com/sirupsen/logrus"

	"github.com/astranet/galaxy/metrics"
)

type {{.FeaturePrefix}}ServiceClient interface {
	{{.FeaturePrefix}}Service
	{{.ClientInterfaceBody}}
}

type {{.FeaturePrefix}}ServiceClientOptions struct {
}

func check{{.FeaturePrefix}}ServiceClientOptions(opt *{{.FeaturePrefix}}ServiceClientOptions) *{{.FeaturePrefix}}ServiceClientOptions {
	if opt == nil {
		opt = &{{.FeaturePrefix}}ServiceClientOptions{}
	}
	return opt
}

type {{.FeaturePrefix}}HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
}

func New{{.FeaturePrefix}}ServiceClient(
	cli {{.FeaturePrefix}}HTTPClient,
	opt *{{.FeaturePrefix}}ServiceClientOptions,
) {{.FeaturePrefix}}ServiceClient {
	return &{{.ClientPrivateName}}{
		opt: check{{.FeaturePrefix}}ServiceClientOptions(opt),
		tags: metrics.Tags{
			"layer":   "service_client",
			"service": "{{.ServiceName}}",
		},
		fields: log.Fields{
			"layer":   "service_client",
			"service": "{{.ServiceName}}",
		},

		cli: cli,
	}
}

type {{.ClientPrivateName}} struct {
	tags metrics.Tags
	fields log.Fields
	opt  *{{.FeaturePrefix}}ServiceClientOptions

	cli {{.FeaturePrefix}}HTTPClient
}

{{.ClientImplementationBody}}

func (s *{{.ClientPrivateName}}) do(req *http.Request) ([]byte, error) {
	resp, err := s.cli.Do(req)
	if err != nil {
		err = fmt.Errorf("{{.ClientPrivateName}}: %v", err)
		return nil, err
	}
	respBody, _ := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		if len(respBody) > 0 {
			err := fmt.Errorf("service error %d: %s", resp.StatusCode, string(respBody))
			return nil, err
		}
		err := fmt.Errorf("service error %d: %s", resp.StatusCode, resp.Status)
		return nil, err
	}
	return respBody, nil
}

func (s *{{.ClientPrivateName}}) newReq(method string, fnName string, v interface{}) *http.Request {
	data, _ := json.Marshal(v)
	req, _ := http.NewRequest(method, fnName, bytes.NewReader(data))
	return req
}

func (s *{{.ClientPrivateName}}) checkRespErr(resp []byte) error {
	var e {{.FeaturePrefix}}ErrorResponse
	json.Unmarshal(resp, &e)
	if len(e.Error) == 0 {
		return nil
	}
	return errors.New(e.Error)
}