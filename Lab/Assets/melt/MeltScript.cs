using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.IO;

public class MeltScript : MonoBehaviour {

	Renderer render;
	MeshCollider meshCollider;

	public AnimationCurve animaCurve;

	public float distance = 10.0f;

	public float duration = 0.0f;
	public float surfPoint = 0.0f;

	public float meltDist = 2.86f;

	// Use this for initialization
	void Start () {
		render = GetComponent<Renderer> ();
		meshCollider = GetComponent<MeshCollider> ();
		//GL.wireframe = true;
		setSurface ();
		render.material.SetFloat("_MeltForm", 0.0f);
		render.material.SetFloat("_MeltDist", 0.0f);
		StartCoroutine ("moveDown", 1.0f);

	}
	
	// Update is called once per frame
	void Update () {
		//Mesh mesh = GetComponent<MeshFilter> ().mesh;
		//meshCollider.sharedMesh = null;
		//meshCollider.sharedMesh = mesh;
	}

	void OnMouseDrag() {

		Vector3 heading = transform.position - Camera.main.transform.position;
		float dist = Vector3.Dot (heading, Camera.main.transform.forward);
		Vector3 mousePos = new Vector3 (Input.mousePosition.x, Input.mousePosition.y, dist);
		Vector3 objPos = Camera.main.ScreenToWorldPoint(mousePos);

		transform.position = objPos;


	}

	void OnMouseUp() {
		setSurface ();
	}

	void OnCollisionEnter(Collision collision) {
		
//		foreach( ContactPoint contact in collision.contacts) {
//			Debug.DrawRay (contact.point, contact.normal, Color.black);
//			//on contact, set the flat distance it can travel.  
//			Debug.Log("collision");
//			Debug.Log (contact.point);
//			float point = contact.point.y + 0.001f;
//			render.material.SetFloat ("_SurfPoint", point);
//		}
	}

	void setSurface() {
		RaycastHit hit;

		if (Physics.Raycast(transform.position, Vector3.down, out hit)) {
			Debug.Log (hit.distance);
			//Debug.Log (hit.transform.position);
			//Debug.Log(hit.distance- transform.position.y);
			surfPoint = -((hit.distance- transform.position.y));
			render.material.SetFloat("_SurfPoint", surfPoint);


		}


	}

	IEnumerator moveDown() {
		Vector3 startPos = transform.position;
		Debug.Log (surfPoint-meshCollider.bounds.size.y/2.0f);
		Vector3 endPos = new Vector3 (transform.position.x, surfPoint-meshCollider.bounds.size.y/2.0f, transform.position.z);
		float timeAtPos = 0.0f;

		while (timeAtPos < duration) {
			timeAtPos += Time.deltaTime;

			float percent = Mathf.Clamp01 (timeAtPos / duration);
			float curveCent = animaCurve.Evaluate (percent);

			transform.position = Vector3.Lerp (startPos, endPos, curveCent);
			float val = Mathf.Lerp (0.0f, 1.0f, curveCent);

			float val2 = Mathf.Lerp (0.0f, meltDist, Mathf.Clamp01(curveCent*2.0f));
			render.material.SetFloat("_MeltDist", val);
			render.material.SetFloat("_MeltVar", 1.0f/(1.0f -val/1.23f));
			render.material.SetFloat ("_MeltForm", val2);
			//render.material.SetFloat("_MeltDist", 0.0f);
			yield return null;
		}

		yield return null;
	}
}
